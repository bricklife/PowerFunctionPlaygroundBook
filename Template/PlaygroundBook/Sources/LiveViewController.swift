//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  An auxiliary source file which is part of the book-level auxiliary sources.
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport
import PlaygroundBluetooth
import CoreBluetooth

private let scanServiceUuid = CBUUID(string: "00001523-1212-EFDE-1523-785FEABCD123")

private let inputValueUuid = CBUUID(string: "00001560-1212-EFDE-1523-785FEABCD123")
private let inputCommandUuid = CBUUID(string: "00001563-1212-EFDE-1523-785FEABCD123")
private let outputCommandUuid = CBUUID(string: "00001565-1212-EFDE-1523-785FEABCD123")

private let buttonStateUuid = CBUUID(string: "00001526-1212-EFDE-1523-785FEABCD123")
private let attachedIoUuid = CBUUID(string: "00001527-1212-EFDE-1523-785FEABCD123")

private let batteryUuid = CBUUID(string: "2A19")

@objc(Book_Sources_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let centralManager = PlaygroundBluetoothCentralManager(services: [scanServiceUuid], queue: .main)
    private var connectionView: PlaygroundBluetoothConnectionView?
    
    private var inputCommandCharacteristic: CBCharacteristic?
    private var outputCommandCharacteristic: CBCharacteristic?
    
    private var connectedIo: [PortId: IOType] = [:] {
        didSet { tableView.reloadData() }
    }
    private var inputValues: [PortId: InputValue] = [:] {
        didSet { tableView.reloadData() }
    }
    private var greenButtonPressing: Bool = false {
        didSet { tableView.reloadData() }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager.delegate = self
        
        let connectionView = PlaygroundBluetoothConnectionView(centralManager: centralManager)
        connectionView.delegate = self
        connectionView.dataSource = self
        
        view.addSubview(connectionView)
        NSLayoutConstraint.activate([
            connectionView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: -64),
            connectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        
        self.connectionView = connectionView
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        sendMessage(.actionButtonPressed(pressed: true, index: sender.tag))
    }
    
    @IBAction func buttonReleased(_ sender: UIButton) {
        sendMessage(.actionButtonPressed(pressed: false, index: sender.tag))
    }
}

extension LiveViewController: PlaygroundBluetoothConnectionViewDelegate {
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, titleFor state: PlaygroundBluetoothConnectionView.State) -> String {
        switch state {
        case .noConnection:
            return NSLocalizedString("Connect Smart Hub", comment: "bt connect title")
        case .connecting:
            return NSLocalizedString("Connecting Smart Hub", comment: "bt connect title")
        case .searchingForPeripherals:
            return NSLocalizedString("Searching for Smart Hub", comment: "bt connect title")
        case .selectingPeripherals:
            return NSLocalizedString("Select a Smart Hub", comment: "bt connect title")
        case .connectedPeripheralFirmwareOutOfDate:
            return NSLocalizedString("Connect to a Different Smart Hub", comment: "bt connect title")
        }
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, firmwareUpdateInstructionsFor peripheral: CBPeripheral) -> String {
        return #function
    }
}

extension LiveViewController: PlaygroundBluetoothConnectionViewDataSource {
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, itemForPeripheral peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?) -> PlaygroundBluetoothConnectionView.Item {
        let name = peripheral.name ?? "Unknown"
        let icon = UIImage()
        let item = PlaygroundBluetoothConnectionView.Item(name: name, icon: icon, issueIcon: icon, firmwareStatus: nil, batteryLevel: nil)
        return item
    }
}

extension LiveViewController: PlaygroundBluetoothCentralManagerDelegate {
    
    public func centralManagerStateDidChange(_ centralManager: PlaygroundBluetoothCentralManager) {
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDiscover peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) {
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, willConnectTo peripheral: CBPeripheral) {
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didConnectTo peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didFailToConnectTo peripheral: CBPeripheral, error: Error?) {
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
    }
}

extension LiveViewController: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            switch characteristic.uuid {
            case inputCommandUuid:
                inputCommandCharacteristic = characteristic
            case outputCommandUuid:
                outputCommandCharacteristic = characteristic
            default:
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        switch characteristic.uuid {
        case attachedIoUuid:
            if let notification = AttachedIoNotification(data: data) {
                print(notification)
                switch notification {
                case .connected(let portId, let ioType):
                    connectedIo[portId] = ioType
                    if let command = InputCommand.defaultInputFormatCommand(ioType: ioType, portId: portId) {
                        inputCommandCharacteristic?.write(data: command)
                        inputCommandCharacteristic?.write(data: InputCommand.readInputValueCommand(portId: portId))
                    }
                    
                case .disconnected(let portId):
                    connectedIo[portId] = nil
                    inputValues[portId] = nil
                }
            }
            
        case inputValueUuid:
            let readStream = DataReadStream(data: data)
            do {
                _ = try readStream.read() as UInt8 // revision
                while readStream.hasBytesAvailable {
                    let portId = try readStream.read() as UInt8
                    guard let ioType = connectedIo[portId] else { return }
                    guard let length = InputCommand.numberOfBytes(ioType: ioType) else { return }
                    if length == 1 {
                        let value = try readStream.read() as UInt8
                        print(portId, ioType, "UInt8", value)
                        inputValues[portId] = .uint(value)
                    }
                    if length == 4 {
                        let value = try readStream.read() as Float32
                        print(portId, ioType, "Float32", value)
                        inputValues[portId] = .float(value)
                        
                        if let port = Hub.Port(rawValue: portId) {
                            switch ioType {
                            case .tiltSensor:
                                guard let direction = TiltSensorDirection(rawValue: value) else { break }
                                sendMessage(.tiltSensorChanged(direction: direction, port: port))
                            case .motionSensor:
                                sendMessage(.motionSensorChanged(distance: Double(value), port: port))
                            default:
                                break
                            }
                        }
                    }
                }
            } catch {
                return
            }
            
        case buttonStateUuid:
            guard data.count > 0 else { return }
            let pressed = (data[0] == 1)
            print("Button:", pressed)
            greenButtonPressing = pressed
            sendMessage(.greenButtonPressed(pressed: pressed))
            
        case batteryUuid:
            guard data.count > 0 else { return }
            let batteryLevel = Double(data[0]) / 100
            print("Battery Level:", batteryLevel)
            connectionView?.setBatteryLevel(batteryLevel, forPeripheral: peripheral)
            
        default:
            return
        }
    }
    
}

extension LiveViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.row < 6 {
            let portId = UInt8(indexPath.row + 1)
            let ioType = connectedIo[portId]
            cell.textLabel?.text = "\(portId): \(ioType?.description ?? "-")"
            
            cell.detailTextLabel?.text = inputValueString(portId: portId) ?? "-"
            
        } else {
            cell.textLabel?.text = "Green Button"
            cell.detailTextLabel?.text = greenButtonPressing ? "Pressing" : "Released"
        }
        
        return cell
    }
    
    private func inputValueString(portId: PortId) -> String? {
        guard let ioType = connectedIo[portId] else { return nil }
        guard let inputValue = inputValues[portId] else { return nil }
        
        switch ioType {
        case .mediumMotor:
            return nil
        case .trainMotor:
            return nil
        case .voltageSensor:
            return "\(inputValue) mV"
        case .currentSensor:
            return "\(inputValue) mA"
        case .piezoSpeaker:
            return nil
        case .rgbLight:
            if case let .uint(value) = inputValue, let color = Color(rawValue: value) {
                return color.description
            }
        case .tiltSensor:
            if case let .float(value) = inputValue, let direction = TiltSensorDirection(rawValue: value) {
                return direction.description
            }
        case .motionSensor:
            return inputValue.description
        case .colorAndDistanceSensor:
            return nil
        case .interactiveMotor:
            return nil
        case .builtInMotor:
            return nil
        case .builtInTiltSensor:
            return nil
        }
        
        return nil
    }
}

extension LiveViewController: UITableViewDelegate {
}

extension LiveViewController: PlaygroundLiveViewMessageHandler {
    /*
     public func liveViewMessageConnectionOpened() {
     // Implement this method to be notified when the live view message connection is opened.
     // The connection will be opened when the process running Contents.swift starts running and listening for messages.
     }
     */
    
    /*
     public func liveViewMessageConnectionClosed() {
     // Implement this method to be notified when the live view message connection is closed.
     // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
     // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
     }
     */
    
    public func receive(_ message: PlaygroundValue) {
        guard let message = Message(value: message) else { return }
        
        switch message {
        case .outputCommand(let data):
            outputCommandCharacteristic?.write(data: data)
        default:
            break
        }
    }
}

extension CBCharacteristic {
    
    func write(data: Data) {
        self.service.peripheral.writeValue(data, for: self, type: .withoutResponse)
    }
}
