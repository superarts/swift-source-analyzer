/// AutomatedCore_StringTests is generated on 2021-06-28 19:35:06 +0000

import Nimble
import Quick
@testable import SwiftWheel

class AutomatedCore_StringTests: QuickSpec {
    override func spec() {
        /// Generated from $PATH/Core/String.swift
        context("In enum 'StringError'") {
        }

        context("In extension 'StringUtilityRequired'") {
        }

        context("In enum 'StringUtility'") {
            /// Ensures 'StringUtility()' isn't nil
            it("should initialize StringUtility") {
                let stringUtility = StringUtility()
                // Methods
                let _ = stringUtility.matches("", pattern: "")
                let _ = try? stringUtility.matched("", pattern: "")
                let _ = try? stringUtility.groups("", pattern: "")
                let _ = stringUtility.firstOccurance("", candidates: [""])
                // Properties

                expect(stringUtility).toNot(beNil())
            }
        }

    }
}