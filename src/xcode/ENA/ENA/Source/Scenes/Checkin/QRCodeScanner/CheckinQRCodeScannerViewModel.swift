////
// 🦠 Corona-Warn-App
//

import Foundation
import AVFoundation
import OpenCombine

final class CheckinQRCodeScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(appConfiguration: AppConfigurationProviding) {
		self.appConfigurationProvider = appConfiguration
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
			  let url = code.stringValue
			 // let traceLocation = TraceLocation(qrCodeString: key)
		else {
			onError?(QRScannerError.codeNotFound)
			return
		}
		verifyQrCode(qrCodeString: url)
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

	var onSuccess: ((TraceLocation) -> Void)?
	var onError: ((QRScannerError) -> Void)?
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
	private let appConfigurationProvider: AppConfigurationProviding
	private var subscriptions: Set<AnyCancellable> = []

	private var isScanningActivated: Bool {
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
					return
				}
				self?.activateScanning()
			}
		default:
			onError?(.cameraPermissionDenied)
		}
	}

	private func verifyQrCode(qrCodeString url: String) {
		appConfigurationProvider.appConfiguration().sink { appConfig in
			
			// 1-Validate URL
			var match: NSTextCheckingResult?
			let descriptor = appConfig.presenceTracingParameters.qrCodeDescriptors.first {
				do {
					let regex = try NSRegularExpression(pattern: $0.regexPattern, options: [.caseInsensitive])
					match = regex.firstMatch(in: url, range: .init(location: 0, length: url.count))
					return match != nil
				} catch {
					Log.error(error.localizedDescription, log: .checkin)
					return false
				}
			}
			// Extract ENCODED_PAYLOAD
			// for some reason we get an extra match at index 0 which is the entire URL so  we need to add an offset of 1 to each index after that to get the correct corresponding parts
			guard let unWrappedMatch = match,
				  let qrDescriptor = descriptor,
				  let versionIndex = descriptor?.versionGroupIndex,
				  let versionRange = Range(unWrappedMatch.range(at: Int(versionIndex) + 1), in: url),
				  let payLoadIndex = descriptor?.encodedPayloadGroupIndex,
				  let payLoadRange = Range(unWrappedMatch.range(at: Int(payLoadIndex) + 1), in: url)
			else {
				Log.error("the QRCode matched none of the regular expressions", log: .checkin)
				self.onError?(QRScannerError.codeNotFound)
				return
			}

			let version = url[versionRange]
			let payLoad = url[payLoadRange]
			let encodingType = EncodingType(rawValue: qrDescriptor.payloadEncoding.rawValue) ?? .unspecified
			guard let traceLocation = TraceLocation(qrCodeString: String(payLoad), encoding: encodingType) else {
				self.onError?(QRScannerError.codeNotFound)
				return
			}
			self.onSuccess?(traceLocation)
		}.store(in: &subscriptions)
	}
}
