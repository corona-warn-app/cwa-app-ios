//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation

/// A small subset of sqlite error codes.
///
/// For further reference see [the complete list of errors](https://sqlite.org/rescode.html ).
enum SQLiteErrorCode: Int32, Error {
	/// The SQLITE_ERROR result code is a generic error code that is used when no other more specific error code is available.
	case generalError = 1

	/// The SQLITE_FULL result code indicates that a write could not complete because the disk is full.
	///
	/// Note that this error can occur when trying to write information into the main database file, or it can also occur when writing into temporary disk files.
	///
	/// Sometimes applications encounter this error even though there is an abundance of primary
	/// disk space because the error occurs when writing into temporary disk files on a system where temporary files are stored
	/// on a separate partition with much less space that the primary disk.
	case sqlite_full = 13

	/// If everything fails, it's aliens.
	case unknown = -1
}
