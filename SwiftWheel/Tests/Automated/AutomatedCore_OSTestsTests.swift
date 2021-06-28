/// AutomatedCore_OSTests is generated on 2021-06-28 19:35:06 +0000

import Nimble
import Quick
@testable import SwiftWheel

class AutomatedCore_OSTests: QuickSpec {
    override func spec() {
        /// Generated from $PATH/Core/OS.swift
        context("In extension 'OSRequired'") {
        }

        context("In enum 'OS'") {
            /// Ensures 'OS()' isn't nil
            it("should initialize OS") {
                let oS = OS()
                // Methods
                let _ = try? oS.absolutePath(relative: "")
                // Properties

                expect(oS).toNot(beNil())
            }
        }

    }
}