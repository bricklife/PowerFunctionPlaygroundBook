//
//  InputFormat.swift
//  Book_Sources
//
//  Created by ooba on 07/08/2018.
//

import Foundation

public class InputCommand {
    
    public static func defaultInputFormatCommand(ioType: IOType, portId: PortId) -> Data? {
        let mode: UInt8
        let interval: UInt8
        let format: UInt8
        switch ioType {
        case .voltageSensor, .currentSensor:
            mode = 0x00
            interval = 0x1e
            format = 0x02
        case .rgbLight:
            mode = 0x00
            interval = 0x01
            format = 0x00
        case .tiltSensor:
            mode = 0x01 // 0: Angle (x,y), 1: Tilt
            interval = 0x01
            format = 0x02
        case .motionSensor:
            mode = 0x00 // 0: Detect, 1: Count, 2: Crash
            interval = 0x01
            format = 0x02
        case .colorAndDistanceSensor:
            mode = 0x00 // 0: Color only
            interval = 0x01
            format = 0x00
        default:
            return nil
        }
        
        return Data(bytes: [0x01, 0x02, portId, ioType.rawValue, mode, interval, 0x00, 0x00, 0x00, format, 0x01])
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
        case .colorAndDistanceSensor:
            return 1
        default:
            return nil
        }
    }
}
