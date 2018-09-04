//
//  InputFormat.swift
//  Book_Sources
//
//  Created by ooba on 07/08/2018.
//

import Foundation

public class InputCommand {
    
    public static func defaultInputFormatCommand(ioType: IOType, portId: PortId) -> Data? {
        switch ioType {
        case .voltageSensor, .currentSensor:
            return Data(bytes: [0x01, 0x02, portId, ioType.rawValue, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x02, 0x01])
        case .rgbLight:
            return Data(bytes: [0x01, 0x02, portId, ioType.rawValue, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01])
        case .tiltSensor:
            return Data(bytes: [0x01, 0x02, portId, ioType.rawValue, 0x01, 0x01, 0x00, 0x00, 0x00, 0x02, 0x01])
        case .motionSensor:
            return Data(bytes: [0x01, 0x02, portId, ioType.rawValue, 0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x01])
        default:
            return nil
        }
    }
    
    public static func readInputFormatCommand(portId: PortId) -> Data {
        return Data(bytes: [0x01, 0x01, portId])
    }
    
    public static func readInputValueCommand(portId: PortId) -> Data {
        return Data(bytes: [0x00, 0x01, portId])
    }
    
    public static func numberOfBytes(ioType: IOType) -> Int? {
        switch ioType {
        case .voltageSensor:
            return 4 // Float32 (mV)
        case .currentSensor:
            return 4 // Float32 (mA)
        case .rgbLight:
            return 1 // UInt8
        case .tiltSensor:
            return 4 // Float32?
        case .motionSensor:
            return 4 // Float32
        default:
            return nil
        }
    }
}
