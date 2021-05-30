import Quick
import Nimble
@testable import SwiftWheel

class SwiftWheelSpec: QuickSpec {
    override func spec() {
        context("Wheel") {
            describe("Example") {
                it("says hello") {
					expect(SwiftWheel.hello).toNot(beNil())
				}
			}
		}
	}
}
