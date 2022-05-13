//
// 🦠 Corona-Warn-App
//

import Foundation

/// A small subset of sqlite error codes.
///
/// For further reference see [the complete list of errors](https://sqlite.org/rescode.html ).
enum SQLiteErrorCode: LocalizedError {

	init(rawValue: Int32) {
		switch rawValue {
		case 1:
			self = .generalError
		case 13:
			self = .sqlite_full
		default:
			self = .unknown(rawValue)
		}
	}
	
	/// The SQLITE_ERROR result code is a generic error code that is used when no other more specific error code is available.
	case generalError

	/// The SQLITE_FULL result code indicates that a write could not complete because the disk is full.
	///
	/// Note that this error can occur when trying to write information into the main database file, or it can also occur when writing into temporary disk files.
	///
	/// Sometimes applications encounter this error even though there is an abundance of primary
	/// disk space because the error occurs when writing into temporary disk files on a system where temporary files are stored
	/// on a separate partition with much less space that the primary disk.
	case sqlite_full

	/// If everything fails, it's aliens.
	case unknown(Int32)
	
	var errorDescription: String? {
		switch self {
		case .generalError:
			return "SQLiteErrorCode.generalError"
		case .sqlite_full:
			return "SQLiteErrorCode.sqlite_full"
		case .unknown(let errorCode):
			return "SQLiteErrorCode.unknown: \(errorCode)"
		}
	}
}
