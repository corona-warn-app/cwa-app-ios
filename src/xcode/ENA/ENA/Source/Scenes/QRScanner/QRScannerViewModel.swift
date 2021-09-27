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
	
	#if targetEnvironment(simulator)
	func fakeHealthCert1Scan() {
		// Vaccination certificate 1 of 2
		parseTheExtractedQRCode(url: "HC1:NCFOXN%TS3DH3ZSUZK+.V0ETD%65NL-AH1YIIOOP-IEDCQN68WA+J7U:CAT4V22F/8X*G3M9JUPY0BX/KR96R/S09T./0LWTKD33238J3HKB5S4VV2 73-E3GG396B-43O058YIZ73423ZQT*EJMD3EV40ATOLN0$4*2D523U53/GNNM0323:QT4XATOB273I97EG3MHF3%8YC3YGFSZV9/0F.8HLVDEFV+0B/S7-SN2H N37J3JFT6LJS$98T5V7AMI5DN9QZ5Y0Q$UPE%5MZ5*T57ZA$O7T6LEJOA+MZ55EIIPEBFVA.QO5VA81K0ECM8CCR1SOOEA7IB6$C94JBPC9AFMO6HNVL6SH.6A4JBY.C4KE5.B--C$JDBLEH-BWOJ96K0DI1PC6LFDNJI-B7DA2KCUDBQEAJJKHHGEC8ZI9$JAQJKLFHDFROZ25%1NXPTG90Q480G:NE--ETAOR7G31BU187$BUPO8 FYL7AEFI+U/2VD3DXQB/OTC1IST0XIJRSE7+56NU%JS8FF%NKG30/A2PYK$ZE550GOV*0")
	}
	
	func fakeHealthCert2Scan() {
		// Vaccination certificate 2 of 2
		parseTheExtractedQRCode(url: "HC1:NCFOXN%TS3DH3ZSUZK+.V0ETD%65NL-AH1YIIOOP-IHECIW18WA$H7EH3AT4V22F/8X*G3M9JUPY0BX/KQ96R/S09T./0LWTKD33238J3HKB5S4VV2 73-E3GG396B-43O058YIZ73423ZQT*EJEG3SP40ATOLN0$4*2D523U53/GNNM0323:QT4XA9Q7UW8X*8* 0$SFIBBLOJ.YV$23KBBHKNSN7+F7V+0B/S7-SN2H N37J3JFT6LJS$98T5V7AMI5DN9QZ5Y0Q$UPE%5MZ5*T57ZA$O7T6LEJOA+MZ55EIIPEBFVA.QO5VA81K0ECM8CCR1SOOEA7IB6$C94JBPC9AFMO6HNVL6SH.6A4JBY.C4KE5.B--C$JDBLEH-BWOJ96K0DI1PC6LFDNJI-B7DA2KCUDBQEAJJKHHGEC8ZI9$JAQJKLFHCEP .G1729XNSP986I-:FTCBIXT3ZTM*D35KYL0:/A2+JYEM$LBHM4*EMSANKAB9U672S HO3OV:5WKA1*07B%F7-V$R4D37K9MYAALFD*V41W7-C86DG")
	}
	
	func fakePCRTest() {
		parseTheExtractedQRCode(url: "https://localhost/fake")
	}
	#endif

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
