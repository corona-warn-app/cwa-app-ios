//
// 🦠 Corona-Warn-App
//

import AVFoundation
import Foundation
import UIKit

class ExposureSubmissionQRScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(
		onSuccess: @escaping (DeviceRegistrationKey) -> Void,
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
			guard let extractedGuid = extractGuid(from: stringValue) else {
				onError(.codeNotFound) { [weak self] in
					self?.activateScanning()
				}
				return
			}
			onSuccess(.guid(extractedGuid))
		}
	}

	/// Filters the input string and extracts a guid.
	/// - the input needs to start with https://localhost/?
	/// - the input must not be longer than 150 chars and cannot be empty
	/// - the guid contains only the following characters: a-f, A-F, 0-9,-
	/// - the guid is a well formatted string (6-8-4-4-4-12) with length 43
	///   (6 chars encode a random number, 32 chars for the uuid, 5 chars are separators)
	func extractGuid(from input: String) -> String? {
		guard !input.isEmpty,
			  input.count <= 150,
			  let urlComponents = URLComponents(string: input),
			  !urlComponents.path.contains(" "),
			  urlComponents.path.components(separatedBy: "/").count == 2,	// one / will separate into two components
			  urlComponents.scheme?.lowercased() == "https",
			  urlComponents.host?.lowercased() == "localhost",
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
	private let captureDevice: AVCaptureDevice?

}
