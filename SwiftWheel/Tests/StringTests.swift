import Quick
import Nimble
import SwiftWheel

class StringUtilitySpec: QuickSpec, StringUtilityRequired {
    override func spec() {
        context("dependency") {
            describe("injection") {
                it("should not be nil") {
                    expect(self.stringUtility).toNot(beNil())
                }
            }
		}
        context("matches") {
            describe("success") {
				it("should match") {
                    expect(self.stringUtility.matches("test1", pattern: "test")).to(beTrue())
                    //expect(self.stringUtility.matches("test", pattern: "$\\w+^")).to(beTrue())
				}
			}
            describe("failure") {
				it("should match") {
                    expect(self.stringUtility.matches("test1", pattern: "Test")).to(beFalse())
                    expect(self.stringUtility.matches("test1", pattern: "$\\w^")).to(beFalse())
				}
			}
		}
        context("captured") {
            describe("success") {
				it("should capture the first") {
                    expect(self.stringUtility.captured("test1 test2", pattern: "(\\w+)").first).to(equal("test1"))
				}
			}
		}
        context("groups") {
            describe("success") {
				it("should capture groups") {
                    expect(try self.stringUtility.groups("test1 test2", pattern: "(\\w+)").count).to(equal(2))
				}
			}
		}
        context("searching") {
            describe("index") {
				it("should find index") {
                    expect(self.stringUtility.index("test1 test2", substring: "test2")).to(equal(6))
				}
				it("should not find index") {
                    expect(self.stringUtility.index("test1 test2", substring: "test3")).to(beNil())
				}
				it("should find first occurance") {
					expect(self.stringUtility.firstOccurance("private struct test { }", candidates: ["enum", "struct", "class"])).to(equal("struct"))
					expect(self.stringUtility.firstOccurance("test1 test2 test3", candidates: ["test2"])).to(equal("test2"))
					expect(self.stringUtility.firstOccurance("test1 test2 test3", candidates: ["test2", "test1", "test3"])).to(equal("test1"))
				}
				it("should find first occurance") {
					expect(self.stringUtility.firstOccurance("test1 test2 test3", candidates: [])).to(beNil())
					expect(self.stringUtility.firstOccurance("test1 test2 test3", candidates: ["test4", "test5"])).to(beNil())
				}
			}
		}
	}
}
