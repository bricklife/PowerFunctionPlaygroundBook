//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import PlaygroundSupport

/// Instantiates a new instance of a live view.
///
/// By default, this loads an instance of `LiveViewController` from `LiveView.storyboard`.
public func instantiateLiveView() -> PlaygroundLiveViewable {
    let storyboard = UIStoryboard(name: "LiveView", bundle: nil)

    guard let viewController = storyboard.instantiateInitialViewController() else {
        fatalError("LiveView.storyboard does not have an initial scene; please set one or update this function")
    }

    guard let liveViewController = viewController as? LiveViewController else {
        fatalError("LiveView.storyboard's initial scene is not a LiveViewController; please either update the storyboard or this function")
    }

    return liveViewController
}

public let hub = Hub()

public func setPower(_ power: Int, port: Hub.Port? = nil) {
    if let port = port {
        hub.setPower(power, port: port)
    } else {
        hub.setPower(power, port: .one)
        hub.setPower(power, port: .two)
    }
}

public func setColor(_ color: Color) {
    hub.setColor(color)
}

public func wait(_ seconds: Int) {
    if seconds > 0 {
        sleep(UInt32(seconds))
    }
}
