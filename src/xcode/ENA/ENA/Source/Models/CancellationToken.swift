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

final class CancellationToken {
	// MARK: Types
	typealias Handler = () -> Void

	// MARK: Creating a Cancellation Token
	init(onCancel: @escaping Handler) {
		self.onCancel = onCancel
		isCancelled = false
	}

	// MARK: Properties
	let onCancel: Handler
	private var isCancelled: Bool

	// MARK: Working with the Cancellation Token
	func cancel() {
		precondition(
			isCancelled == false,
			"Cancelling an already cancelled operation is not supported and indicates a programmer error."
		)
		isCancelled = true
		onCancel()
	}
}
