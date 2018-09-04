//
//  AttachedIoNotification.swift
//  Book_Sources
//
//  Created by ooba on 07/08/2018.
//

import Foundation

public enum AttachedIoNotification {
    
    case connected(PortId, IOType)
    case disconnected(PortId)
}

extension AttachedIoNotification {
    
    public init?(data: Data) {
        guard data.count >= 2 else { return nil }
        
        let portId = data[0]
        switch data[1] {
        case 0x00:
            self = .disconnected(portId)
            
        case 0x01:
            guard data.count >= 4 else { return nil }
            guard let ioType = IOType(rawValue: data[3]) else { return nil }
            self = .connected(portId, ioType)
            
        default:
            return nil
        }
    }
}

extension AttachedIoNotification: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .connected(let portId, let ioType):
            return "Connected \(ioType) into \(portId)"
        case .disconnected(let portId):
            return "Disconnected an I/O from \(portId)"
        }
    }
}
