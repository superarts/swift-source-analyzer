/// AutomatedSource_ModelTests is generated on 2021-06-28 19:35:06 +0000

import Nimble
import Quick
@testable import SwiftWheel

class AutomatedSource_ModelTests: QuickSpec {
    override func spec() {
        /// Generated from $PATH/Source/Model.swift
        context("In enum 'SourceError'") {
        }

        context("In struct 'SourceScanner'") {
            /// Ensures 'SourceScanner()' isn't nil
            it("should initialize SourceScanner") {
                let sourceScanner = SourceScanner()
                // Methods

                // Properties

                expect(sourceScanner).toNot(beNil())
            }
        }

    }
}