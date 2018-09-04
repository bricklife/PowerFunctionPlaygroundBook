//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//

import Foundation
import PlaygroundSupport

//#-end-hidden-code

func onActionButtonPressed(pressed: Bool, index: Int) {
    setColor(pressed ? .red : .blue)
}

func onGreenButtonPressed(pressed: Bool) {
    setPower(pressed ? 50 : 0)
}

func onTiltSensorChanged(direction: TiltSensorDirection, port: Hub.Port) {
    switch direction {
    case .neutral:
        setColor(.blue)
    case .backward:
        setColor(.red)
    case .right:
        setColor(.purple)
    case .left:
        setColor(.green)
    case .forward:
        setColor(.orange)
    case .unknown:
        setColor(.off)
    }
}

func onMotionSensorChanged(distance: Double, port: Hub.Port) {
    setPower(100 - Int(distance * 10))
}

//#-hidden-code
hub.onActionButtonPressed = onActionButtonPressed
hub.onGreenButtonPressed = onGreenButtonPressed
hub.onTiltSensorChanged = onTiltSensorChanged
hub.onMotionSensorChanged = onMotionSensorChanged

PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code
