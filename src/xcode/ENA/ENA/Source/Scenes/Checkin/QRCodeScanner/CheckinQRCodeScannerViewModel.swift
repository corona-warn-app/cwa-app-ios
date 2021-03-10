////
// 🦠 Corona-Warn-App
//

import Foundation
import AVFoundation
import OpenCombine

final class CheckinQRCodeScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	override init() {
		self.captureDevice = AVCaptureDevice.default(for: .video)
		super.init()
	}

	// MARK: - Protocol AVCaptureMetadataOutputObjectsDelegate

	func metadataOutput(
		_: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from _: AVCaptureConnection
	) {
		guard let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject,
			  let route = Route(code.stringValue),
			  case let Route.checkin(key) = route
		else {
			onError?(QRScannerError.codeNotFound)
			return
		}

		let data = key.base32DecodedString()
		Log.debug("Data found: \(String(describing: data))")

		// creates a fake event for the moment
		let checkin = Checkin(id: 0, traceLocationGUID: "", traceLocationVersion: 0, traceLocationType: .type1, traceLocationDescription: "", traceLocationAddress: "", traceLocationStart: Date(), traceLocationEnd: Date(), traceLocationDefaultCheckInLengthInMinutes: 0, traceLocationSignature: "", checkinStartDate: Date(), checkinEndDate: Date(), targetCheckinEndDate: Date(), createJournalEntry: false)

		onSuccess?(checkin)
	}

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

	var onSuccess: ((Checkin) -> Void)?
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
			Log.info("AVCaptureDevice.authorized - enable qr code scanner", log: .checkin)
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

}
