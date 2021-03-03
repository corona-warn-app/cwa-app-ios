////
// 🦠 Corona-Warn-App
//

import Foundation
import AVFoundation

final class CheckInQRCodeScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	override init() {
		self.captureDevice = AVCaptureDevice.default(for: .video)
		super.init()
	}

	// MARK: - Overrides

	// MARK: - Protocol AVCaptureMetadataOutputObjectsDelegate

	func metadataOutput(
		_: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from _: AVCaptureConnection
	) {
		didScan(metadataObjects: metadataObjects)
	}

	// MARK: - Public

	// MARK: - Internal

	lazy var captureSession: AVCaptureSession? = {
		guard let currentCaptureDevice = captureDevice,
			let captureDeviceInput = try? AVCaptureDeviceInput(device: currentCaptureDevice) else {
			onError?(.cameraPermissionDenied)
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

//	let captureSession: AVCaptureSession

	var onSuccess: ((String) -> Void)?
	var onError: ((QRScannerError) -> Void)?

	func activateScanning() {
		captureSession?.startRunning()
	}

	func deactivateScanning() {
		captureSession?.stopRunning()
	}

	// MARK: - Private

	private let captureDevice: AVCaptureDevice?

	private var isScanningActivated: Bool {
		captureSession?.isRunning ?? false
	}

	func setupCaptureSession() {
		guard let currentCaptureDevice = captureDevice,
			let captureDeviceInput = try? AVCaptureDeviceInput(device: currentCaptureDevice) else {
			onError?(.cameraPermissionDenied)
			return
		}

		let metadataOutput = AVCaptureMetadataOutput()
		captureSession?.addInput(captureDeviceInput)
		captureSession?.addOutput(metadataOutput)
		metadataOutput.metadataObjectTypes = [.qr]
		metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
	}

	private func startCaptureSession() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			Log.info("AVCaptureDevice.authorized - enable qr code scanner")
			activateScanning()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { [weak self] isAllowed in
				guard isAllowed else {
					self?.onError?(.cameraPermissionDenied)
					return
				}
				self?.activateScanning()
			}
		default:
			onError?(.cameraPermissionDenied)
		}
	}

	private func didScan(metadataObjects: [MetadataObject]) {
		guard isScanningActivated,
			  let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject,
			  let stringValue = code.stringValue else {
			onError?(QRScannerError.codeNotFound)
			return
		}
		deactivateScanning()
		onSuccess?(stringValue)
	}

}
