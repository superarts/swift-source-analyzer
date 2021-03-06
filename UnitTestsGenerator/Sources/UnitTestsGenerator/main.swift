import ArgumentParser
import SwiftWheel
import Foundation

enum GeneratorError: Error {
	case generic(message: String)
}

struct UnitTestsGenerator: ParsableCommand, StringUtilityRequired, OSRequired {
    static var configuration = CommandConfiguration(
        abstract: "Generate unit tests.",
        version: "0.0.1"
    )

    //@Argument(help: "Command")
    //var command: String

    @Flag(name: .long, help: "Verbose mode.")
    var verbose: Bool = false

    @Flag(name: .long, help: "Do NOT execute any shell command at all. Not supported by LillyUtilityCLI classes yet. DEBUG ONLY.")
    var dryRun: Bool = false

    @Option(name: .long, help: "Allow functions of these classes to be tested. Can be multiple.")
	var allowClass: [String] = []

    @Option(name: .long, help: "Ignored classes. Can be multiple.")
	var ignoreClass: [String] = []

    @Option(name: .long, help: "Ignored files. Can be multiple.")
	var ignoreFilename: [String] = []

    @Option(name: .long, help: "Ignored function namesi. Can be multiple.")
	var ignoreFunction: [String] = []

    @Option(name: .long, help: "Input path with Swift files.")
	var inputPath: String?

    @Option(name: .long, help: "Input filename. To process multiple files, use --input-path instead.")
	var inputFilename: String?

    @Option(name: .long, help: "Output path. Warning: ALL CONTENTS INSIDE WILL BE DELETED!!!")
	var outputPath: String?

    @Option(name: .long, help: "Output filename. Write all tests to a single file.")
	var outputFilename: String?

    @Option(name: .long, help: "Additional header string other than importing Quick & Nimble. Can be multiple.")
	var headerString: [String] = []

    private struct Const {
		struct Color {
			static let reset = "\u{001B}[m"
			static let lightCyan = "\u{001B}[1;36m"
			static let lightRed = "\u{001B}[1;31m"

			static let command = lightCyan
			static let output = lightRed
		}
    }

    func run() throws {
		let filenames: [String]
		if let inputPath = inputPath {
			let filenameList = try execute("find '\(inputPath)' -name '*.swift'", message: "Finding swift files")
			filenames = filenameList.split(whereSeparator: \.isNewline).map { String($0) }
			log("Found \(filenames.count) file(s)")
		} else if let inputFilename = inputFilename {
			filenames = [inputFilename]
		} else {
			throw GeneratorError.generic(message: "input path and filename can't both be empty.")
		}

		if let outputPath = outputPath {
			try execute("rm -rf \(outputPath)")
			try execute("mkdir -p \(outputPath)")
		}

		for filename in filenames {
			log("Building class list from: \(filename)")
			do {
				try Builder.shared.build(filename: filename)
			} catch let error {
				log("Skipping due to error: \(error)")
			}
		}
		log("Found class(es): \(Builder.shared.classes.count)")

		var fullOutput = ""
		for filename in filenames {
			var output = header(filename: filename)
			guard !ignoreFilename.contains(where: filename.contains) else {
				log("Ignoring file: \(filename)")
				continue
			}
			let code = try process(filename: filename)
			output += code
			output += footer
			//log(code)

			fullOutput += output
			fullOutput += "\n"

			if let outputPath = outputPath {
				let outputFilename = "\(outputPath)/\(testClassName(filename: filename))Tests.swift"
				let url = URL(fileURLWithPath: outputFilename)
				try output.write(to: url, atomically: true, encoding: .utf8)
			}
		}
		if let outputFilename = outputFilename {
			let url = URL(fileURLWithPath: outputFilename)
			try fullOutput.write(to: url, atomically: true, encoding: .utf8)
		}

		// The following "single file" writer should probably be deleted.
		/*
		var output = header
		for filename in filenames {
			guard !ignoreFilename.contains(where: filename.contains) else {
				log("Ignoring file: \(filename)")
				continue
			}
			let code = try process(filename: filename)
			output += code
			print(code)
		}
		output += footer

        let url = URL(fileURLWithPath: outputFilename)
		try output.write(to: url, atomically: true, encoding: .utf8)
		*/
    }

	// MARK: - helpers

    private func log(_ message: String) {
        // TODO: use `ConsoleLogger` from `LillyUtility/Logger`
        guard verbose else {
            return
        }
        print("DEBUG " + message)
    }

	private func log(message: String, command: String) {
		log("\(message) command: \(Const.Color.command)\(command)\(Const.Color.reset)")
	}

	// Run and print log
	@discardableResult private func execute(_ cmd: String, message: String = "", ignoreErrorOutput: Bool = false, disableDryRun: Bool = false) throws -> String {
		log(message: message, command: cmd)
		let output: String
		if !dryRun || disableDryRun {
			output = try os.shell(cmd, ignoreErrorOutput: ignoreErrorOutput)
		} else {
			output = "DRY RUN"
		}
		log("\(message) output: \(Const.Color.output)\(output)\(Const.Color.reset)")
		return output
	}

	// MARK: - processor

	private func header(filename: String) -> String { 
		"""
		/// \(testClassName(filename: filename)) is generated on \(Date())

		import Nimble
		import Quick
		\(headerString.joined(separator: "\n"))

		class \(testClassName(filename: filename)): QuickSpec {
		\(spaces(4))override func spec() {

		"""
	}

	private var footer: String { """
		\(spaces(4))}
		}
		""" }

	private func spaces(_ count: Int) -> String {
		String(repeating: " ", count: count)
	}

	private func shortFilename(_ filename: String) -> String {
		if let inputPath = inputPath {
			return filename.replacingOccurrences(of: inputPath, with: "")
		} else {
			return filename
		}
	}

	private func testClassName(filename: String) -> String {
		return "Automated" + 
			shortFilename(filename)
			.trimmingCharacters(in: ["/"])
			.replacingOccurrences(of: ".swift", with: "")
			.replacingOccurrences(of: "./", with: "")
			.replacingOccurrences(of: " ", with: "")
			.replacingOccurrences(of: "/", with: "_")
			.replacingOccurrences(of: "+", with: "_")
			.replacingOccurrences(of: ".", with: "_") +
			"Tests"
	}

    private func process(filename: String) throws -> String {
        let url = URL(fileURLWithPath: filename)
		var output = "\(spaces(8))/// Generated from $PATH\(shortFilename(filename))\n"

        let content = try String(contentsOf: url, encoding: .utf8)
		let classes = try ClassType.matched(from: content)
		for aClass in classes {
			//	\t\t// \(aClass.name)\n
			output += """
				\(spaces(8))context(\"In \(aClass.category.rawValue) '\(aClass.name)'\") {\n
				"""
			output += process(class: aClass)
			output += "\(spaces(8))}\n\n"
		}
        return output
    }

	private func process(class aClass: ClassType) -> String {
		var output = ""

		guard aClass.accessLevel != .private else {
			return ""
		}
		guard aClass.accessLevel != .fileprivate else {
			return ""
		}

		guard !ignoreClass.contains(aClass.name) else {
			log("Ignoring class: \(aClass.name)")
			return ""
		}

		for initializer in aClass.initializers {
			output += process(initializer: initializer, in: aClass)
		}

		guard aClass.category == .class else {
			log("Skipping non-class type: \(aClass.category) \(aClass.name)")
			return output
		}

		guard aClass.initializers.isEmpty else {
			log("Skipping default initializer: \(aClass.category) \(aClass.name)")
			return output
		}

		guard let (_, superInitializer, initializerParameters) = getBaseClass(aClass) else {
			log("Unknown class: \(aClass.name), \(aClass.baseClassName ?? "N/A")")
			return output
		}

		output += allCode(
			class: aClass,
			initializerCode: "\(aClass.name)\(initializerParameters)",
			comment: "should initialize \(aClass.name) from super class initializer \(superInitializer)"
		)
		return output
	}

	/// Find the root base class
	private func getBaseClass(_ theClass: ClassType) -> (baseClassName: String, superInitializer: String, initializerParameters: String)? {
		var aClass = theClass
		var shouldBreak = false
		//log("----")
		while !shouldBreak {
			//log("----")
			//log(aClass.name)
			//log(aClass.baseClassName ?? "N/A")
			guard let baseClassName = aClass.baseClassName else {
				return nil
			}
			//log(baseClassName)
			if let superInitializer = KnownClasses.defaultValue(typeName: baseClassName),
				let initializerParameters = KnownClasses.parentInitializerParameters(typeName: baseClassName)
			{
				//log("found")
				return (baseClassName: baseClassName, superInitializer: superInitializer, initializerParameters: initializerParameters)
			} else if let c = Builder.shared.classes[baseClassName] {
				//log("next")
				aClass = c
			} else {
				//log("break")
				shouldBreak = true
			}
		}
		return nil
	}

	/// All test case code
	private func allCode(class aClass: ClassType, initializerCode: String, comment: String) -> String {
		let variableName = aClass.name.prefix(1).lowercased() + aClass.name.dropFirst()
		let funcsCode = allFuncsCode(class: aClass, variableName: variableName)
		let varCode = allVarCode(class: aClass, variableName: variableName)
		//log("variables: \(aClass.vars): \(varCode)")
		return """
			\(spaces(12))/// Ensures '\(initializerCode)' isn't nil
			\(spaces(12))it(\"\(comment)\") {
			\(spaces(16))let \(variableName) = \(initializerCode)
			\(spaces(16))// Methods
			\(funcsCode)
			\(spaces(16))// Properties
			\(varCode)
			\(spaces(16))expect(\(variableName)).toNot(beNil())
			\(spaces(12))}

			"""
	}

	/// Returns: lines of "variableName.functionName(paramList: ...)"
	private func allFuncsCode(class aClass: ClassType, variableName: String) -> String {
		// stringUtility.matches(str, pattern: "^UI.*")
		if let (baseClassName, _, _) = getBaseClass(aClass), !allowClass.contains(aClass.name), [
			"UIViewController",
			"UIPageViewController",
			"UITableViewCell",
			"UIView",
			"UITableViewHeaderFooterView",
			"UICollectionReusableView",
		].contains(baseClassName) {
			log("Unsupported UIKit component: \(baseClassName)")
			return "\(spaces(16))/// UIKit functions are not supported for now."
		}
		var funcs = [String]()
		for function in aClass.funcs {
			if let f = process(function: function, className: aClass.name, variableName: variableName) {
				funcs.append("\(spaces(16))\(function.returnTypeName != nil ? "let _ = " : "")\(f)")
			}
		}
		return funcs.joined(separator: "\n")
	}

	private func allVarCode(class aClass: ClassType, variableName: String) -> String {
		aClass.vars.compactMap { v in
			guard !v.accessLevel.isPrivate else {
				return nil
			}
			if v.category.isStatic {
				return "\(spaces(16))let _ = \(aClass.name).\(v.name)"
			} else {
				return "\(spaces(16))let _ = \(variableName).\(v.name)"
			}
		}.joined(separator: "\n")
	}

	private func process(initializer: InitializerType, in aClass: ClassType) -> String {
		guard initializer.accessLevel != .private else {
			return ""
		}
		guard initializer.accessLevel != .fileprivate else {
			return ""
		}
		// TODO: disable deprecated and unavailable items

		// TODO: support the following cases
		if initializer.doesThrow {
			//initializerCode = "try \(initializerCode)"
			return ""
		}
		if initializer.isOptional {
			//comment = "/// Ensure '\(initializerCode)' doesn't throw"
			//print(comment)
			//print("expect { \(initializerCode) }.to(throwAssertion())")
			return ""
		}

		guard let param = process(parameters: initializer.parameters) else {
			return ""
		}

		return allCode(
			class: aClass,
			initializerCode: "\(aClass.name)\(param)",
			comment: "should initialize \(aClass.name)"
		)
	}

	/// Returns: nil when any parameter in `parameters` doesn't have a default value
	private func process(parameters: [ParameterType]) -> String? {
		guard !parameters.isEmpty else {
			return "()"
		}

		var array = [String]()
		for parameter in parameters {
			guard let output = process(parameter: parameter) else {
				return nil
			}
			array.append(output)
		}
		return "(\(array.joined(separator: ", ")))"
	}

	/// Returns: nil when `parameter` doesn't have a default value
	private func process(parameter: ParameterType) -> String? {
		//print("\t" + parameter.typeName)
		//print("\(KnownClasses.allCases.map { $0.rawValue })||||\(parameter.typeName)")
		//if !KnownClasses.allCases.map { $0.rawValue }.contains(parameter.typeName) { }
		
		guard let defaultValue = KnownClasses.defaultValue(typeName: parameter.typeName, isOptional: parameter.isOptional) else {
			return nil
		}

		// Exclude e.g. `init(coder _: NSCoder)`
		guard parameter.internalName != "_" else {
			return nil
		}

		let name = (parameter.name == "_") ? "" : "\(parameter.name): "
		//print("-1-\(name)---")
		//print("-2-\(defaultValue)---")
		return "\(name)\(defaultValue)"
	}

	private func process(function: FuncType, className: String, variableName: String) -> String? {
		guard !ignoreFunction.contains(function.name) else {
			return nil
		}
		guard !function.accessLevel.isPrivate else {
			return nil
		}
		guard let param = process(parameters: function.parameters) else {
			return nil
		}
		//print("\(function.name); \(param)")

		if function.category.isStatic {
			return "\(function.doesThrow ? "try? " : "")\(className).\(function.name)\(param)"
		} else if function.category == .instance {
			return "\(function.doesThrow ? "try? " : "")\(variableName).\(function.name)\(param)"
		} else {
			//throws GeneratorError.generic(message: "Unexpected func category found in: \(f)")
			return nil
		}
	}
}

UnitTestsGenerator.main()
