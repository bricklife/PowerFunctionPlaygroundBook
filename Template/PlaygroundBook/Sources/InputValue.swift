//
//  InputValue.swift
//  Book_Sources
//
//  Created by ooba on 08/08/2018.
//

import Foundation

public enum InputValue {
    case uint(UInt8)
    case float(Float32)
}

extension InputValue: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .uint(let value):
            return value.description
        case .float(let value):
            return value.description
        }
    }
}

public enum TiltSensorDirection: UInt8 {
    case neutral    = 0
    case backward   = 3
    case right      = 5
    case left       = 7
    case forward    = 9
    case unknown    = 10
}

extension TiltSensorDirection: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .neutral:
            return "Neutral"
        case .backward:
            return "Backward"
        case .right:
            return "Right"
        case .left:
            return "Left"
        case .forward:
            return "Forward"
        case .unknown:
            return "Unknown"
        }
    }
}
