//
// 🦠 Corona-Warn-App
//

import AVFoundation
import Foundation
import UIKit

class ExposureSubmissionQRScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(
		onSuccess: @escaping (CoronaTestQRCodeInformation) -> Void,
		onError: @escaping (QRScannerError, _ reactivateScanning: @escaping () -> Void) -> Void
	) {
		self.onSuccess = onSuccess
		self.onError = onError
		self.captureSession = AVCaptureSession()
		self.captureDevice = AVCaptureDevice.default(for: .video)
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

	let onError: (QRScannerError, _ reactivateScanning: @escaping () -> Void) -> Void
	let captureSession: AVCaptureSession

	var isScanningActivated: Bool {
		captureSession.isRunning
	}

	/// get current torchMode by device state
	var torchMode: TorchMode {
		guard let device = captureDevice,
			  device.hasTorch else {
			return .notAvailable
		}

		switch device.torchMode {
		case .off:
			return .lightOff
		case .on:
			return .lightOn
		case .auto:
			return .notAvailable
		@unknown default:
			return .notAvailable
		}
	}

	func activateScanning() {
		captureSession.startRunning()
	}

	func deactivateScanning() {
		captureSession.stopRunning()
	}

	func setupCaptureSession() {
		/// this special case is need to avoid system alert while UI tests are running
		#if DEBUG
		if isUITesting {
			activateScanning()
			return
		}
		#endif
		guard let currentCaptureDevice = captureDevice,
			let caputureDeviceInput = try? AVCaptureDeviceInput(device: currentCaptureDevice) else {
			onError(.cameraPermissionDenied) { Log.error("Failed to setup AVCaptureDeviceInput", log: .ui) }
			return
		}

		let metadataOutput = AVCaptureMetadataOutput()
		captureSession.addInput(caputureDeviceInput)
		captureSession.addOutput(metadataOutput)
		metadataOutput.metadataObjectTypes = [.qr]
		metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
	}

	func startCaptureSession() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			Log.info("AVCaptureDevice.authorized - enable qr code scanner")
			activateScanning()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { [weak self] isAllowed in
				guard isAllowed else {
					self?.onError(.cameraPermissionDenied) {
						Log.error("camera requestAccess denied - stop here we can't go on", log: .ui)
					}
					return
				}
				self?.activateScanning()
			}
		default:
			onError(.cameraPermissionDenied) {
				Log.info(".cameraPermissionDenied - stop here we can't go on", log: .ui)
			}
		}
	}

	func stopCaptureSession() {
		deactivateScanning()
	}

	/// toggle torchMode between on / off after finish call optional completion handler
	func toggleFlash(completion: (() -> Void)? = nil ) {
		guard let device = captureDevice,
			  device.hasTorch else {
			return
		}

		defer {
			device.unlockForConfiguration()
			completion?()
		}

		do {
			try device.lockForConfiguration()

			if device.torchMode == .on {
				device.torchMode = .off
			} else {
				try device.setTorchModeOn(level: 1.0)
			}

		} catch {
			Log.error(error.localizedDescription, log: .api)
		}
	}

	func didScan(metadataObjects: [MetadataObject]) {
		guard isScanningActivated else {
			Log.info("Scanning not stopped from previous run")
			return
		}
		deactivateScanning()

		if let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject, let stringValue = code.stringValue {
			guard let testType = extractGuid(from: stringValue) else {
				onError(.codeNotFound) { [weak self] in
					self?.activateScanning()
				}
				return
			}
			onSuccess(testType)
		}
	}

	/// Filters the input string and extracts a guid.
	/// - the input needs to start with https://localhost/?
	/// - the input must not be longer than 150 chars and cannot be empty
	/// - the guid contains only the following characters: a-f, A-F, 0-9,-
	/// - the guid is a well formatted string (6-8-4-4-4-12) with length 43
	///   (6 chars encode a random number, 32 chars for the uuid, 5 chars are separators)
	func extractGuid(from input: String) -> CoronaTestQRCodeInformation? {
		// general checks for both PCR and Rapid tests
		guard !input.isEmpty,
			  let urlComponents = URLComponents(string: input),
			  !urlComponents.path.contains(" "),
			  urlComponents.scheme?.lowercased() == "https" else {
			return nil
		}
		
		// specific checks based on test type
		if urlComponents.host?.lowercased() == "localhost" {
			
			guard input.count <= 150,
				  urlComponents.path.components(separatedBy: "/").count == 2,	// one / will separate into two components    1 for rapid
				  let candidate = urlComponents.query,
				  candidate.count == 43,
				  let matchings = candidate.range(
					of: #"^[0-9A-Fa-f]{6}-[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$"#,
					options: .regularExpression
				  ) else {
				return nil
			}
			return matchings.isEmpty ? nil : .pcr(candidate)
			
		} else if urlComponents.host?.lowercased() == "s.coronawarn.app" {
			
			guard urlComponents.path.components(separatedBy: "/").count == 1,	// one / will separate into two components    1 for rapid
				  let payloadUrl = urlComponents.fragment,
				  let candidate = urlComponents.query,
				  candidate.count == 3 else {
				return nil
			}
			
			// extract payload
			guard let testInformation = RapidTestInformation(payload: payloadUrl) else {
				return nil
			}
			
			return .antigen(testInformation, payloadUrl)
		} else {
			return nil
		}
	}

	// MARK: - Private

	private let onSuccess: (CoronaTestQRCodeInformation) -> Void
	private let captureDevice: AVCaptureDevice?

}

// to be removed after merging 2.0

extension Data {
	/// Instantiates data by decoding a base64url string into base64
	///
	/// - Parameter string: A base64url encoded string
	init?(base64URLEncoded string: String) {
		self.init(base64Encoded: string.toggleBase64URLSafe(on: false))
	}
	/// Encodes the string into a base64url safe representation
	///
	/// - Returns: A string that is base64 encoded but made safe for passing
	///            in as a query parameter into a URL string
	func base64URLEncodedString() -> String {
		return self.base64EncodedString().toggleBase64URLSafe(on: true)
	}
}

extension String {
	/// Encodes or decodes into a base64url safe representation
	///
	/// - Parameter on: Whether or not the string should be made safe for URL strings
	/// - Returns: if `on`, then a base64url string; if `off` then a base64 string
	func toggleBase64URLSafe(on: Bool) -> String {
		if on {
			// Make base64 string safe for passing into URL query params
			let base64url = self.replacingOccurrences(of: "/", with: "_")
				.replacingOccurrences(of: "+", with: "-")
				.replacingOccurrences(of: "=", with: "")
			return base64url
		} else {
			// Return to base64 encoding
			var base64 = self.replacingOccurrences(of: "_", with: "/")
				.replacingOccurrences(of: "-", with: "+")
			// Add any necessary padding with `=`
			if !base64.count.isMultiple(of: 4) {
				base64.append(String(repeating: "=", count: 4 - base64.count % 4))
			}
			return base64
		}
	}
	
}
