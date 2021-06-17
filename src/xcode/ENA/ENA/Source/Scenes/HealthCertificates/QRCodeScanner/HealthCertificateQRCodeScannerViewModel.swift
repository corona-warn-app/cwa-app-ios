////
// 🦠 Corona-Warn-App
//

import Foundation
import AVFoundation

class HealthCertificateQRCodeScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		onSuccess: @escaping (HealthCertifiedPerson, HealthCertificate) -> Void,
		onError: ((QRScannerError) -> Void)?
	) {
		self.healthCertificateService = healthCertificateService
		self.captureDevice = AVCaptureDevice.default(for: .video)
		self.onSuccess = onSuccess
		self.onError = onError

		super.init()
	}

	// MARK: - Protocol AVCaptureMetadataOutputObjectsDelegate

	func metadataOutput(
		_: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from _: AVCaptureConnection
	) {
		didScan(metadataObjects: metadataObjects)
	}
	
	func didScan(metadataObjects: [MetadataObject]) {
		guard isScanningActivated else {
			Log.info("Scanning not stopped from previous run")
			return
		}
		deactivateScanning()

		guard
			let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject,
			let scannedQRCodeString = code.stringValue
		else {
			Log.error("Vaccination QRCode verification Failed, invalid metadataObject", log: .vaccination)
			onError?(QRScannerError.codeNotFound)
			return
		}

		didScan(base45: scannedQRCodeString)
	}

	func didScan(base45: String) {
		let result = healthCertificateService.registerHealthCertificate(base45: base45)
		switch result {
		case let .success((healthCertifiedPerson, healthCertificate)):
			self.onSuccess(healthCertifiedPerson, healthCertificate)
		case .failure(let registrationError):
			// wrap RegistrationError into an QRScannerError.other error
			self.onError?(QRScannerError.other(registrationError))
		}
	}

	// MARK: - Internal

	lazy var captureSession: AVCaptureSession? = {
		#if targetEnvironment(simulator)
		return nil
		#else
		guard let currentCaptureDevice = captureDevice,
			let captureDeviceInput = try? AVCaptureDeviceInput(device: currentCaptureDevice) else {
			onError?(.cameraPermissionDenied)
			Log.error("Failed to setup AVCaptureDeviceInput", log: .ui)
			return nil
		}

		let metadataOutput = AVCaptureMetadataOutput()
		let captureSession = AVCaptureSession()
		captureSession.addInput(captureDeviceInput)
		captureSession.addOutput(metadataOutput)
		metadataOutput.metadataObjectTypes = [.qr]
		metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
		return captureSession
		#endif
	}()

	var onSuccess: (HealthCertifiedPerson, HealthCertificate) -> Void
	var onError: ((QRScannerError) -> Void)?

	var isScanningActivated: Bool {
		captureSession?.isRunning ?? false
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
		captureSession?.startRunning()
	}

	func deactivateScanning() {
		captureSession?.stopRunning()
	}

	func toggleFlash() {
		guard let device = captureDevice,
			  device.hasTorch else {
			return
		}

		defer { device.unlockForConfiguration() }

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
	
	func startCaptureSession() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			Log.info("AVCaptureDevice.authorized - enable qr code scanner", log: .qrCode)
			activateScanning()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { [weak self] isAllowed in
				guard isAllowed else {
					self?.onError?(.cameraPermissionDenied)
					Log.error("camera requestAccess denied - stop here we can't go on", log: .ui)
					return
				}
				self?.activateScanning()
			}
		default:
			onError?(.cameraPermissionDenied)
			Log.info(".cameraPermissionDenied - stop here we can't go on", log: .ui)
		}
	}

	#if DEBUG

	#endif

	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
	private let captureDevice: AVCaptureDevice?
}
