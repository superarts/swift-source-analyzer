import Quick
import Nimble
@testable import SwiftWheel

class SourceSpec: QuickSpec {
    override func spec() {
        context("Source analyzer") {
            describe("Scanner") {
                it("should scan") {
					let scanner = SourceScanner()
					expect(scanner).toNot(beNil())
					do {
						let result = try scanner.scan(filename: "file:///Users/leo/prj/mac/swift-source-analyzer/SwiftWheel/Sources/Source/Model.swift")
						print("DEBUG scan result: \(result)")
					} catch let error {
						print("DEBUG scan failed: \(error)")
					}
				}
			}
		}
	}
}
