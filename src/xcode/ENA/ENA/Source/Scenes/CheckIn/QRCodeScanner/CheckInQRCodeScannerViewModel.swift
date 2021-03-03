////
// 🦠 Corona-Warn-App
//

import Foundation
import AVFoundation
import OpenCombine

final class CheckInQRCodeScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	override init() {
		self.captureDevice = AVCaptureDevice.default(for: .video)
		self.qrCodes = []
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

	@OpenCombine.Published private (set) var qrCodes: [AVMetadataObject]

	func activateScanning() {
		captureSession?.startRunning()
	}

	func deactivateScanning() {
		captureSession?.stopRunning()
		qrCodes = []
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

	private func didScan(metadataObjects: [AVMetadataObject]) {

		qrCodes = metadataObjects.filter({ metaDataObject -> Bool in
			metaDataObject.type == AVMetadataObject.ObjectType.qr
		})

/*
		if metadataObj.type == AVMetadataObject.ObjectType.qr {
				// If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
				let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
				qrCodeFrameView?.frame = barCodeObject!.bounds

				if metadataObj.stringValue != nil {
					messageLabel.text = metadataObj.stringValue
				}
			}
*/

		guard isScanningActivated,
			  let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject,
			  let route = Route(code.stringValue) else {
			Log.debug("wrong QR Code type", log: .event)
			return
		}

		if case let Route.event(event) = route {
			deactivateScanning()
			onSuccess?(event)
		}
	}

}
