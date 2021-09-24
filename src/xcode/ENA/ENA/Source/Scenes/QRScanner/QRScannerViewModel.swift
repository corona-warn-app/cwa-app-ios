//
// 🦠 Corona-Warn-App
//

import AVFoundation

protocol QRCodeParsable {
	/// Function to be called to parse a qrCode.
	/// - Parameters:
	///   - qrCode: The scanned qrCode as String
	///   - completion: If parsing was successful, we receive a QRCodeResult. If there encountered an error, we receive a QRCodeParserError
	func parse(
		qrCode: String,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	)
}

class QRScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		appConfiguration: AppConfigurationProviding,
		markCertificateAsNew: Bool,
		markCoronaTestAsNew: Bool,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	) {
		self.captureDevice = AVCaptureDevice.default(for: .video)
		
		self.healthCertificateService = healthCertificateService
		self.appConfiguration = appConfiguration
		self.markCertificateAsNew = markCertificateAsNew
		self.markCoronaTestAsNew = markCoronaTestAsNew
		self.completion = completion
		
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
			completion(.failure(.scanningError(.scanningDeactivated)))
			Log.error("Scanning not stopped from previous run")
			return
		}

		deactivateScanning()
		guard let code = metadataObjects.first(where: { $0 is MetadataMachineReadableCodeObject }) as? MetadataMachineReadableCodeObject,
			  let url = code.stringValue,
			  !url.isEmpty
		else {
			Log.error("Scanned QRCode URL in empty or invalid")
			completion(.failure(.scanningError(.codeNotFound)))
			return
		}
		parseTheExtractedQRCode(url: url)
	}
	
	var completion: ((Result<QRCodeResult, QRCodeParserError>) -> Void)

	// MARK: - Internal
	
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
	
	var isScanningActivated: Bool {
		captureSession?.isRunning ?? false
	}
	
	lazy var captureSession: AVCaptureSession? = {
		guard let currentCaptureDevice = captureDevice,
			let captureDeviceInput = try? AVCaptureDeviceInput(device: currentCaptureDevice) else {
			completion(.failure(.scanningError(.cameraPermissionDenied)))
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
			Log.info("AVCaptureDevice.authorized - enable qr code scanner", log: .checkin)
			activateScanning()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { [weak self] isAllowed in
				guard isAllowed else {
					self?.completion(.failure(.scanningError(.cameraPermissionDenied)))
					Log.error("camera requestAccess denied - stop here we can't go on", log: .ui)
					return
				}
				self?.activateScanning()
			}
		default:
			completion(.failure(.scanningError(.cameraPermissionDenied)))
			Log.info(".cameraPermissionDenied - stop here we can't go on", log: .ui)
		}
	}

	// MARK: - Private

	private func parseTheExtractedQRCode(url: String) {
		// Check the prefix to know which type
		// if we go directly and try to parse we might get an incorrect error
		// e.g: scanning a PCR QRCode and trying to parse it at a health-certificate, we will get a healthCertificate related error
		// which is incorrect and it should be a Corona test error, so we need to have an idea about the type of qrcode before paring it
		
		let traceLocationsPrefix = "https://e.coronawarn.app"
		let antigenTestPrefix = "https://s.coronawarn.app"
		let pcrTestPrefix = "https://localhost"
		let healthCertificatePrefix = "HC1:"

		if url.prefix(traceLocationsPrefix.count) == traceLocationsPrefix {
			// it is trace Locations QRCode
			parser = CheckinQRCodeParser(
				appConfigurationProvider: appConfiguration
			)
		} else if url.prefix(antigenTestPrefix.count) == antigenTestPrefix || url.prefix(pcrTestPrefix.count) == pcrTestPrefix {
			// it is a test
			parser = CoronaTestsQRCodeParser()
		} else if url.prefix(healthCertificatePrefix.count) == healthCertificatePrefix {
			// it is a digital certificate
			parser = HealthCertificateQRCodeParser(
				healthCertificateService: healthCertificateService,
				markAsNew: markCertificateAsNew
			)
		}
		
		guard let parser = parser else {
			Log.error("QRCode parser not initialized, Scanned code prefix doesn't match any of the scannable structs", log: .qrCode, error: nil)
			completion(.failure(.scanningError(.codeNotFound)))
			return
		}

		parser.parse(qrCode: url) { result in
			self.completion(result)
			self.parser = nil
		}
	}
	
	private let captureDevice: AVCaptureDevice?
	private let appConfiguration: AppConfigurationProviding
	private let healthCertificateService: HealthCertificateService
	private let markCertificateAsNew: Bool
	private let markCoronaTestAsNew: Bool

	private var parser: QRCodeParsable?

}
