//
//  Hub.swift
//  Book_Sources
//
//  Created by ooba on 07/08/2018.
//

import Foundation
import PlaygroundSupport

public class Hub {
    
    public enum Port: UInt8 {
        case one = 0x01
        case two = 0x02
    }
    
    private let proxy: PlaygroundRemoteLiveViewProxy?
    
    public var onActionButtonPressed: ((Bool, Int) -> Void)?
    public var onGreenButtonPressed: ((Bool) -> Void)?
    public var onTiltSensorChanged: ((TiltSensorDirection, Hub.Port) -> Void)?
    public var onMotionSensorChanged: ((Double, Hub.Port) -> Void)?
    
    init() {
        proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy
        proxy?.delegate = self
    }
    
    public func write(data: Data) {
        proxy?.sendMessage(.outputCommand(data: data))
    }
    
    public func setPower(_ power: Int, port: Port) {
        let portId = port.rawValue
        let payload = UInt8(bitPattern: Int8(power))
        write(data: Data(bytes: [portId, 0x01, 0x01, payload]))
    }
    
    public func setColor(_ color: Color) {
        let portId = UInt8(0x06)
        let payload = color.rawValue
        write(data: Data(bytes: [portId, 0x04, 0x01, payload]))
    }
}

extension Hub: PlaygroundRemoteLiveViewProxyDelegate {
    
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
    }
    
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        guard let message = Message(value: message) else { return }

        switch message {
        case .actionButtonPressed(let pressed, let index):
            onActionButtonPressed?(pressed, index)
        case .greenButtonPressed(let pressed):
            onGreenButtonPressed?(pressed)
        case .tiltSensorChanged(let direction, let port):
            onTiltSensorChanged?(direction, port)
        case .motionSensorChanged(let distance, let port):
            onMotionSensorChanged?(distance, port)
        default:
            break
        }
    }
}
