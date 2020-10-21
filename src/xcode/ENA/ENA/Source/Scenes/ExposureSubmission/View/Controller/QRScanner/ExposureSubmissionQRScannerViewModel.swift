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
		isScanningActivated: Bool = false,
		onSuccess: @escaping (DeviceRegistrationKey) -> Void,
		onError: @escaping (QRScannerError, _ reactivateScanning: @escaping () -> Void) -> Void
	) {
		self.onSuccess = onSuccess
		self.onError = onError
		self.isScanningActivated = isScanningActivated
		self.captureSession = AVCaptureSession()
		super.init()
		setupCaptureSession()
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

	let captureSession: AVCaptureSession

	func startCaptureSession() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			Log.info("AVCaptureDevice.authorized - enable qr code scanner")
			activateScanning()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { [weak self] isAllowed in
				guard isAllowed else {
					self?.onError(.cameraPermissionDenied) {
						Log.info(".cameraPermissionDenied - stop here we can't go on")
					}
					return
				}
				self?.activateScanning()
			}
		default:
			onError(.cameraPermissionDenied) {
				Log.info("permission denied - what to do next?")
			}
		}
	}

	private func setupCaptureSession() {
		guard let captureDevice = AVCaptureDevice.default(for: .video),
			  let caputureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
			onError(.cameraPermissionDenied) {}
			return
		}

		let metadataOutput = AVCaptureMetadataOutput()
		captureSession.addInput(caputureDeviceInput)
		captureSession.addOutput(metadataOutput)
		metadataOutput.metadataObjectTypes = [.qr]
		metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
	}

	func stop() {
		deactivateScanning()
	}

	func didScan(metadataObjects: [MetadataObject]) {
		guard isScanningActivated else {
			Log.error("Scanning not stopped from previous run")
			return
		}
		deactivateScanning()

		if let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject, let stringValue = code.stringValue {
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
		guard !input.isEmpty,
			  input.count <= 150,
			  let urlComponents = URLComponents(string: input),
			  urlComponents.scheme == "https",
			  urlComponents.host == "localhost",
			  let candidate = urlComponents.query,
			  candidate.count == 43,
			  let matchings = candidate.range(
				of: #"^[0-9A-Fa-f]{6}-[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$"#,
				options: .regularExpression
			  ) else {
			return nil
		}
		return matchings.isEmpty ? nil : candidate
	}

	// MARK: - Private

	private let onSuccess: (DeviceRegistrationKey) -> Void
	private let onError: (QRScannerError, _ reactivateScanning: @escaping () -> Void) -> Void

	private(set) var isScanningActivated: Bool

	private func activateScanning() {
		if isScanningActivated {
			return
		}
		captureSession.startRunning()
		isScanningActivated = true
	}

	private func deactivateScanning() {
		if !isScanningActivated {
			return
		}
		captureSession.stopRunning()
		isScanningActivated = false
	}

}
