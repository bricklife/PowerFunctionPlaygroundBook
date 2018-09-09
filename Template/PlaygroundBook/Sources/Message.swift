//
//  Message.swift
//  Book_Sources
//
//  Created by ooba on 08/08/2018.
//

import Foundation
import PlaygroundSupport

enum Message {
    // Hub -> LiveView
    case outputCommand(data: Data)
    
    // LiveView -> Hub
    case actionButtonPressed(pressed: Bool, index: Int)
    case greenButtonPressed(pressed: Bool)
    case tiltSensorChanged(direction: TiltSensorDirection, port: Hub.Port)
    case motionSensorChanged(distance: Int, port: Hub.Port)
    case colorSensorChanged(color: Color, port: Hub.Port)
}

extension Dictionary where Key == String, Value == PlaygroundSupport.PlaygroundValue {
    
    func boolean(key: Key) -> Bool? {
        guard let entry = self[key], case .boolean(let value) = entry else { return nil }
        return value
    }
    
    func integer(key: Key) -> Int? {
        guard let entry = self[key], case .integer(let value) = entry else { return nil }
        return value
    }
    
    func double(key: Key) -> Double? {
        guard let entry = self[key], case .floatingPoint(let value) = entry else { return nil }
        return value
    }
    
    func string(key: Key) -> String? {
        guard let entry = self[key], case .string(let value) = entry else { return nil }
        return value
    }
    
    func data(key: Key) -> Data? {
        guard let entry = self[key], case .data(let value) = entry else { return nil }
        return value
    }
}

extension Message {
    
    init?(value: PlaygroundValue) {
        guard case .dictionary(let dict) = value else { return nil }
        guard let cmd = dict.string(key: "cmd") else { return nil }
        
        switch cmd {
        case "outputCommand":
            guard let data = dict.data(key: "data") else { return nil }
            self = .outputCommand(data: data)
            
        case "actionButtonPressed":
            guard let pressed = dict.boolean(key: "pressed") else { return nil }
            guard let index = dict.integer(key: "index") else { return nil }
            self = .actionButtonPressed(pressed: pressed, index: index)
            
        case "greenButtonPressed":
            guard let pressed = dict.boolean(key: "pressed") else { return nil }
            self = .greenButtonPressed(pressed: pressed)
            
        case "tiltSensorChanged":
            guard let direction = dict.integer(key: "direction").flatMap({ TiltSensorDirection(rawValue: UInt8($0)) }) else { return nil}
            guard let port = dict.integer(key: "port").flatMap({ Hub.Port(rawValue: UInt8($0)) }) else { return nil}
            self = .tiltSensorChanged(direction: direction, port: port)
            
        case "motionSensorChanged":
            guard let distance = dict.integer(key: "distance") else { return nil}
            guard let port = dict.integer(key: "port").flatMap({ Hub.Port(rawValue: UInt8($0)) }) else { return nil}
            self = .motionSensorChanged(distance: distance, port: port)
            
        case "colorSensorChanged":
            guard let color = dict.integer(key: "color").flatMap({ Color(rawValue: UInt8($0)) }) else { return nil}
            guard let port = dict.integer(key: "port").flatMap({ Hub.Port(rawValue: UInt8($0)) }) else { return nil}
            self = .colorSensorChanged(color: color, port: port)

        default:
            return nil
        }
    }
    
    var playgroundValue: PlaygroundValue? {
        switch self {
        case .outputCommand(let data):
            return .dictionary(["cmd": .string("outputCommand"), "data": .data(data)])
            
        case .actionButtonPressed(let pressed, let index):
            return .dictionary(["cmd": .string("actionButtonPressed"), "pressed": .boolean(pressed), "index": .integer(index)])

        case .greenButtonPressed(let pressed):
            return .dictionary(["cmd": .string("greenButtonPressed"), "pressed": .boolean(pressed)])
            
        case .tiltSensorChanged(let direction, let port):
            return .dictionary(["cmd": .string("tiltSensorChanged"), "direction": .integer(Int(direction.rawValue)), "port": .integer(Int(port.rawValue))])
            
        case .motionSensorChanged(let distance, let port):
            return .dictionary(["cmd": .string("motionSensorChanged"), "distance": .integer(distance), "port": .integer(Int(port.rawValue))])
            
        case .colorSensorChanged(let color, let port):
            return .dictionary(["cmd": .string("colorSensorChanged"), "color": .integer(Int(color.rawValue)), "port": .integer(Int(port.rawValue))])
        }
    }
}

extension PlaygroundRemoteLiveViewProxy {
    
    func sendMessage(_ message: Message) {
        if let value = message.playgroundValue {
            send(value)
        }
    }
}

extension PlaygroundLiveViewMessageHandler {
    
    func sendMessage(_ message: Message) {
        if let value = message.playgroundValue {
            send(value)
        }
    }
}
