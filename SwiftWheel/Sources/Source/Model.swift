import Foundation

public enum SourceError: Error {
	case generic(message: String)
}

// TODO: this should be removed as it's not part of the library
public struct SourceScanner {
    //let filename: String
    //public let classes: [ClassType]
    
    public func scan(filename: String) throws -> [ClassType] {
		var output = ""
        //print("Scanning:", filename)
		guard let url = URL(string: filename) else {
			throw SourceError.generic(message: "File not found: \(filename)")
		}
        let content = try String(contentsOf: url, encoding: .utf8)
		/*
        print("---- read file...")
        print(content)
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}
        print("---- removed comments...")
        print(content)
		*/
        //print("---- finding classes...")
		let classes = try ClassType.matched(from: content)
		for aClass in classes {
			//print(aClass.name)
			guard aClass.accessLevel != .private else {
				continue
			}
			guard aClass.accessLevel != .fileprivate else {
				continue
			}
			for initializer in aClass.initializers {
				guard initializer.accessLevel != .private else {
					continue
				}
				guard initializer.accessLevel != .fileprivate else {
					continue
				}

				var code = ""
				var comment = ""

				if initializer.parameters.isEmpty {
					code = "\(aClass.name)()"
				} else {
					//print(initializer.parameters)
					var isAllKnown = true
					var parameters = [String]()
					for parameter in initializer.parameters {
						//print("\t" + parameter.typeName)
						//print("\(KnownClasses.allCases.map { $0.rawValue })||||\(parameter.typeName)")
						//if !KnownClasses.allCases.map { $0.rawValue }.contains(parameter.typeName) { }
						
						guard let defaultValue = KnownClasses.defaultValue(typeName: parameter.typeName, isOptional: parameter.isOptional) else {
							isAllKnown = false
							break
						}

						// Exclude e.g. `init(coder _: NSCoder)`
						guard parameter.internalName != "_" else {
							isAllKnown = false
							break
						}

						let name = (parameter.name == "_") ? "" : parameter.name
						parameters.append("\(name): \(defaultValue)")
					}
					if isAllKnown {
						code = "\(aClass.name)(\(parameters.joined(separator: ", ")))"
					}
				}

				guard !code.isEmpty else {
					//print("skipping")
					continue
				}

				// TODO: support the following cases
				if initializer.doesThrow {
					code = "try \(code)"
					continue
				}
				if initializer.isOptional {
					comment = "/// Ensure '\(code)' doesn't throw"
					//print(comment)
					//print("expect { \(code) }.to(throwAssertion())")
					continue
				}
				// TODO: disable deprecated and unavailable items

				comment = "Ensures '\(code)' isn't nil"
				let test = """
				/// \(comment)
				it(\"should initialize \(aClass.name)\") {
				    expect(\(code)).toNot(beNil())
				}
				"""
				//print(test + "\n")
				output += test + "\n\n"
			}
		}
        //print("Scanner end ---")
		print(output)
        return classes
    }

    public init() { }
    /*
    init(filename: String) {
        //self.filename = filename
        self.classes = scan(filename: filename)
    }
    */
}
