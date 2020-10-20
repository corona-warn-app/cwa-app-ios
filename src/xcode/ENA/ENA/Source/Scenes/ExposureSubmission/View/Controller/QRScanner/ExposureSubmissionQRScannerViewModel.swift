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

import AVFoundation
import Foundation
import UIKit

class ExposureSubmissionQRScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(
		isScanningActivated: Bool,
		onSuccess: @escaping (DeviceRegistrationKey) -> Void,
		onError: @escaping (QRScannerError, _ reactivateScanning: @escaping () -> Void) -> Void,
		onCancel: @escaping () -> Void
	) {
		self.isScanningActivated = isScanningActivated
		self.onSuccess = onSuccess
		self.onError = onError
		self.onCancel = onCancel
	}

	// MARK: - Protocol AVCaptureMetadataOutputObjectsDelegate

	func metadataOutput(
		_: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from _: AVCaptureConnection
	) {
		didScan(metadataObjects: metadataObjects)
	}

	// MARK: - Internal

	let onError: (QRScannerError, _ reactivateScanning: @escaping () -> Void) -> Void
	let onCancel: () -> Void

	func activateScanning() {
		isScanningActivated = true
	}

	func deactivateScanning() {
		isScanningActivated = false
	}

	func didScan(metadataObjects: [MetadataObject]) {
		guard isScanningActivated else { return }

		if let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject, let stringValue = code.stringValue {
			deactivateScanning()

			guard let extractedGuid = extractGuid(from: stringValue) else {
				onError(.codeNotFound) { [weak self] in
					self?.activateScanning()
				}

				return
			}

			onSuccess(.guid(extractedGuid))
		}
	}

	/// Sanitizes the input string and extracts a guid.
	/// - the input needs to start with https://localhost/?
	/// - the input must not ne longer than 150 chars and cannot be empty
	/// - the guid contains only the following characters: a-f, A-F, 0-9,-
	/// - the guid is a well formatted string (6-8-4-4-4-12) with length 43
	///   (6 chars encode a random number, 32 chars for the uuid, 5 chars are separators)
	func extractGuid(from input: String) -> String? {
		guard let urlComponents = URLComponents(string: input),
			  urlComponents.scheme == "https",
			  urlComponents.host == "localhost",
			  let queryString = urlComponents.query,
			  queryString.count == 43
			  else {
			return nil
		}

		return queryString

//		https://localhost/?62AF54-00DE966F-3727-45CB-B403-419E8134ECBC

//		guard
//			!input.isEmpty,
//			input.count <= 150,
//			let regex = try? NSRegularExpression(
//				pattern: "^https:\\/\\/localhost\\/\\?(?<GUID>[0-9A-Fa-f]{6}-[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})$"
//			),
//			let match = regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.count))
//		else { return nil }

		/*
		guard let range = Range(match.range(withName: "GUID"), in: input) else { return nil }

		let candidate = String(input[range])
		guard !candidate.isEmpty, candidate.count == 43 else { return nil }

		return candidate
*/
	}

	// MARK: - Private

	private var isScanningActivated: Bool

	private let onSuccess: (DeviceRegistrationKey) -> Void

}
