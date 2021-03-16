////
// 🦠 Corona-Warn-App
//

import Foundation

/// Reads large files
/// Modernized version of this implementation: https://stackoverflow.com/a/24648951/194585
class StreamReader {
	private let encoding: String.Encoding
	private let chunkSize: Int
	private let buffer: NSMutableData
	private let delimData: Data

	private var fileHandle: FileHandle
	private var atEof: Bool = false

	/// A StreamReader for large files. Reads them line by line.
	///
	/// - Parameters:
	///   - url: the url to the file to read
	///   - delimiter: the line delimiter; defaults to `\n`
	///   - encoding: the file encoding to expect; defaults to `.utf8`
	///   - chunkSize: the buffer size during the read process; defaults to 4096 bytes
	init?(at url: URL, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
		do {
			let fileHandle = try FileHandle(forReadingFrom: url)
			guard
				let delimData = delimiter.data(using: encoding),
				let buffer = NSMutableData(capacity: chunkSize)
			else {
				preconditionFailure("Cannot initialize StreamReader for file at \(url)")
				return nil
			}
			self.chunkSize = chunkSize
			self.encoding = encoding
			self.fileHandle = fileHandle
			self.delimData = delimData
			self.buffer = buffer
		} catch {
			preconditionFailure(error.localizedDescription)
			return nil
		}
	}

	/// A StreamReader for large files. Reads them line by line.
	///
	/// - Parameters:
	///   - path: the path to the file to read
	///   - delimiter: the line delimiter; defaults to `\n`
	///   - encoding: the file encoding to expect; defaults to `.utf8`
	///   - chunkSize: the buffer size during the read process; defaults to 4096 bytes
	convenience init?(at path: String, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
		guard let url = URL(string: path) else { return nil }
		self.init(at: url, delimiter: delimiter, encoding: encoding, chunkSize: chunkSize)
	}

	deinit {
		self.close()
	}

	/// Return next line, or nil on EOF.
	func nextLine() -> String? {
		if atEof {
			return nil
		}

		// Read data chunks from file until a line delimiter is found:
		var range = buffer.range(of: delimData, options: [], in: NSRange(location: 0, length: buffer.length))
		while range.location == NSNotFound {
			let tmpData = fileHandle.readData(ofLength: chunkSize)
			if tmpData.isEmpty {
				// EOF or read error.
				atEof = true
				if buffer.length > 0 {
					// Buffer contains last line in file (not terminated by delimiter).
					let line = String(data: buffer as Data, encoding: encoding)

					buffer.length = 0
					return line as String?
				}
				// No more lines.
				return nil
			}
			buffer.append(tmpData)

			range = buffer.range(of: delimData, options: [], in: NSRange(location: 0, length: buffer.length))
		}

		// Convert complete line (excluding the delimiter) to a string:
		let line = NSString(data: buffer.subdata(with: NSRange(location: 0, length: range.location)), encoding: encoding.rawValue)
		// Remove line (and the delimiter) from the buffer:
		buffer.replaceBytes(in: NSRange(location: 0, length: range.location + range.length), withBytes: nil, length: 0)

		return line as String?
	}

	/// Start reading from the beginning of file.
	func rewind() {
		fileHandle.seek(toFileOffset: 0)
		buffer.length = 0
		atEof = false
	}

	/// Close the underlying file. No reading must be done after calling this method.
	func close() {
		fileHandle.closeFile()
	}
}
