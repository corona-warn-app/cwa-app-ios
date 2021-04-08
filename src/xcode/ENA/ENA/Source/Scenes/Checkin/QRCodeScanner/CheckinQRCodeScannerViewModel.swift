////
// 🦠 Corona-Warn-App
//

import Foundation
import AVFoundation

class CheckinQRCodeScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(
		verificationHelper: QRCodeVerificationHelper,
		appConfiguration: AppConfigurationProviding,
		onSuccess: @escaping(TraceLocation) -> Void,
		onError: ((CheckinQRScannerError) -> Void)?
	) {
		self.appConfiguration = appConfiguration
		self.verificationHelper = verificationHelper
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
		guard let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject,
			  let url = code.stringValue,
			  !url.isEmpty
		else {
			onError?(CheckinQRScannerError.codeNotFound)
			return
		}
		verificationHelper.verifyQrCode(
			qrCodeString: url,
			appConfigurationProvider: appConfiguration,
			onSuccess: { [weak self] traceLocation in
				self?.onSuccess(traceLocation)
			},
			onError: { [weak self] error in
				self?.onError?(error)
			}
		)
	}
	// MARK: - Internal

	lazy var captureSession: AVCaptureSession? = {
		
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
	}()

	private let appConfiguration: AppConfigurationProviding
	private let verificationHelper: QRCodeVerificationHelper
	var onSuccess: (TraceLocation) -> Void
	var onError: ((CheckinQRScannerError) -> Void)?
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

	// MARK: - Private

	private let captureDevice: AVCaptureDevice?
	var isScanningActivated: Bool {
		captureSession?.isRunning ?? false
	}

	func startCaptureSession() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			Log.info("AVCaptureDevice.authorized - enable qr code scanner", log: .checkin)
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
}
