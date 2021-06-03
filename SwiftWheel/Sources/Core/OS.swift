import Foundation

public protocol OSRequired {
    var os: OS { get }
}

public extension OSRequired {
    var os: OS { OS() }
}

public enum OS {
	/// OS errors
    public enum Error: Swift.Error {
        //case failure
        case processFailure(code: Int, output: String, message: String)
        case invalidFile(filename: String)
        case invalidPath(path: String)
    }

	/// File types that handles logic related with file extension, MIME type, etc.
	// TODO: this enum is working in progress.
	public enum FileType: String, CaseIterable {
		case csv, zip

		var extensionName: String { rawValue }

		var mimeType: String {
			switch self {
			case .csv: return "text/csv"
			case .zip: return "application/zip"
			}
		}
	}

    /// Getting a discardable `String` output from a shell command
    /// `throws` when failure
    @discardableResult 
    public func shell(_ command: String, ignoreErrorOutput: Bool = false) throws -> String {
        let result = process(command, ignoreErrorOutput: ignoreErrorOutput)
        switch result {
        case let .success(output):
            return output
        case let .failure(error):
            throw error
        }
    }

    /// Getting a `Result` from a shell command
    public func process(_ command: String, ignoreErrorOutput: Bool = false) -> Result<String, Swift.Error> {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        let errorPipe = Pipe()
        process.standardError = errorPipe

        process.launch()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: outputData, encoding: .utf8) else {
            return .failure(StringError.encodingFailure(data: outputData))
        }

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        guard let errorOutput = String(data: errorData, encoding: .utf8) else {
            return .failure(StringError.encodingFailure(data: errorData))
        }

        process.waitUntilExit()
        let status = Int(process.terminationStatus)

        if status == 0, (errorOutput.isEmpty || ignoreErrorOutput) {
            return .success(output)
        } else {
            return .failure(OS.Error.processFailure(code: status, output: output, message: errorOutput))
        }
    }

    /// Too many `../` may result invalid path
    public func absolutePath(relative path: String) throws -> String {
        let pwd = try shell("pwd").replacingOccurrences(of: "\n", with: "")
        let filename = "/\(pwd)/\(path)"
        return (filename as NSString).standardizingPath
        /*
        guard let url = URL(string: filename) else {
            throw Error.invalidFilename(filename: filename)
        }
        print("DEBUG url:", url)
        return url.absoluteString
        */
    }

    case pure
    init() { self = .pure }
}
