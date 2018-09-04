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

setColor(.red)

let powers = [20, 40, 60, 80, 100]

for power in powers {
    setPower(power)
    wait(1)
}

setPower(0)

setColor(.blue)
