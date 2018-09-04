//
//  Color.swift
//  Book_Sources
//
//  Created by ooba on 07/08/2018.
//

import Foundation

public enum Color: UInt8 {
    case off = 0x00
    case pink
    case purple
    case blue
    case lightBlue
    case lightGreen
    case green
    case yellow
    case orange
    case red
    case white
}

extension Color: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .off:
            return "Off"
        case .pink:
            return "Pink"
        case .purple:
            return "Purple"
        case .blue:
            return "Blue"
        case .lightBlue:
            return "Light Blue"
        case .lightGreen:
            return "Light Green"
        case .green:
            return "Green"
        case .yellow:
            return "Yellow"
        case .orange:
            return "Orange"
        case .red:
            return "Red"
        case .white:
            return "White"
        }
    }
}
