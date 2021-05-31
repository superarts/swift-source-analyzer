import Quick
import Nimble
import SwiftWheel

class SourceSpec: QuickSpec {
    override func spec() {
        context("Source analyzer") {
            describe("Scanner") {
                it("should scan") {
					let scanner = SourceScanner()
					expect(scanner).toNot(beNil())
					do {
						let result = try scanner.scan(filename: "file:///Users/leo/prj/mac/swift-source-analyzer/SwiftWheel/Tests/Example.swift")
						print("DEBUG scan result: \(result.count)")
					} catch let error {
						print("DEBUG scan failed: \(error)")
					}
					print(CommentType.block.patterns)
				}
			}
		}
        context("CommentType") {
            describe("Block comments") {
				let comment0 = "// test1"
				let comment1 = " /// test2"
				let comment2 = "  //// test3 ////"

                it("should match single line comment") {
					let matched = try CommentType.line.matched(from: "test \(comment0)")
					expect(matched.first).to(equal(comment0))
				}
                it("should match multiple comments") {
					let source = "Test1\n\(comment0)\nTest2\n\(comment1)\nTest3\n\(comment2)\nTest4"
					let matched = try CommentType.line.matched(from: source)
					//print(source + "\n----\n\(matched)")
					expect(comment0).to(contain(matched[0]))
					expect(comment1).to(contain(matched[1]))
					expect(comment2).to(contain(matched[2]))
				}
                it("should strip multiple comments") {
					let source = "\(comment0) test0\ntest1\n\(comment1)\ntest2\n\(comment2)\ntest3"
					let stripped = try CommentType.line.stripped(from: source)
					//print(source + "\n----\n" + stripped)
					expect(stripped).toNot(contain(comment0))
					expect(stripped).toNot(contain(comment1))
					expect(stripped).toNot(contain(comment2))
				}
			}
            describe("Block comments") {
				let comment0 = "/* test1 */"
				let comment1 = "/* test2\n\nline2.2 */"
				let comment2 = """
				/*
				 * test 3
				 * line 3.2
				 */
				"""

                it("should match single line comment") {
					let matched = try CommentType.block.matched(from: "test \(comment0) test")
					expect(matched.first).to(equal(comment0))
				}
                it("should match multi-lines comment") {
					let matched = try CommentType.block.matched(from: "test \(comment1) test")
					expect(matched.first).to(equal(comment1))
				}
                it("should match multi-lines inline comment") {
					let matched = try CommentType.block.matched(from: "test \(comment2) test")
					expect(matched.first).to(equal(comment2))
				}
                it("should match multiple comments") {
					let matched = try CommentType.block.matched(from: "test \(comment0) test \(comment1) test \(comment2) test")
					expect(matched[0]).to(equal(comment0))
					expect(matched[1]).to(equal(comment1))
					expect(matched[2]).to(equal(comment2))
				}
                it("should strip multiple comments") {
					let source = "\(comment0)\ntest1\n\(comment1)\ntest2\n\(comment2)\ntest3"
					let stripped = try CommentType.block.stripped(from: source)
					//print(source + "\n----\n" + stripped)
					expect(stripped).toNot(contain(comment0))
					expect(stripped).toNot(contain(comment1))
					expect(stripped).toNot(contain(comment2))
				}
			}
		}
	}
}
