//
// 🦠 Corona-Warn-App
//

import AVFoundation

class QRScannerViewModel: NSObject, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		appConfiguration: AppConfigurationProviding,
		qrCodeParser: QRCodeParsable,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	) {
		self.captureDevice = AVCaptureDevice.default(for: .video)
		
		self.healthCertificateService = healthCertificateService
		self.appConfiguration = appConfiguration
		self.parser = qrCodeParser
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
		// swiftlint:disable:next line_length
		parseTheExtractedQRCode(url: "HC1:6BF-70690T9WJWG.FKY*4GO0LYV8HOHL76T2FBBD%1*70HS8FN0 XCU3RWY05NCVPKD97TK0F90$PC5$CUZCY$5Y$5TPCBEC7ZKI3D -C QE+8DWKEW.C68DHECAECZEDOEDI3D8WEHY8LTAGY8LPCG/D68DSB8LB81C9MC9GVC*JC1A60:63W5Y96AL6KECTHG4KCD3DX47B46IL6646H*6Z/E5JD%96IA74R6646307Q$D.UDRYA 96NF6L/5SW6Y57B$D% D3IA4W5646946846.96XJC +D3KC.SCXJCCWENF6PF63W5Q47C46WJCT3EHS8%JC QE/IAYJC5LEW34U3ET7DXC9 QE-ED8%EWJC0FDFG6AIA%G7X+AQB9746HS80:54IB:Q6SW6$A8$1BS6A8N9LCB0Z9 Y98OA*09KCB*46X6AITAG47 S8058PPA2%AG*RAQ3/WPR0N$I4I.9 328BLT22QZI-P0LQ5 NEQIT XO35AMTR2EQQWTKO81M1TTK FSF52DN799FC6FRFN9CQWYN42W21")
	}
	
	func fakeHealthCert2Scan() {
		// Vaccination certificate 2 of 2
		// swiftlint:disable:next line_length
		parseTheExtractedQRCode(url: "HC1:6BF-70690T9WJWG.FKY*4GO0LYV8HOHL76T2FBBD%1*70HS8FN0 XCC4RWY05NCDQKD97TK0F90$PC5$CUZCY$5Y$5TPCBEC7ZKI3D -C QE+8DWKEW.C68DHECAECZEDOEDI3D8WEHY8LTAGY8LPCG/D68DSB8LB81C9MC9GVC*JC1A60:63W5Y96AL6KECTHG4KCD3DX47B46IL6646H*6Z/E5JD%96IA74R6646307Q$D.UDRYA 96NF6L/5SW6Y57B$D% D3IA4W5646946846.96XJC$+D3KC.SCXJCCWENF6PF63W5Q47+96WJCT3EHS8%JC QE/IAYJC5LEW34U3ET7DXC9 QE-ED8%EWJC0FDFG6AIA%G7X+AQB9746HS80:54IB:Q6SW6$A8YH9.96XIBU%6S6AZ:6F:6RG8RTA TAS0AD%6O96 S8B78GHES1HZ55WS8IP722B8FG22DUP2X5I$CTROO7PUGDQ770XY1DZ6.AT XRSH7-FKGJQBGM*7ISU2.A9:$MX72DYFRAEPKO6HDDNIT0")
	}
	
	func fakePCRTestScan() {
		parseTheExtractedQRCode(url: "https://localhost/?5C5FEF-5C5FEFF6-0126-4C49-9351-2749EB58CA33")
	}
	
	func fakePCRTest2Scan() {
		parseTheExtractedQRCode(url: "https://localhost/fake")
	}
	
	func fakeEventScan() {
		parseTheExtractedQRCode(url: "https://e.coronawarn.app?v=1#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA")
	}

	func fakeTicketValidation() {
		parseTheExtractedQRCode(
			url: """
				{
					"protocol": "DCCVALIDATION",
					"protocolVersion": "1.0.0",
					"serviceIdentity": "Betreiber_ValidationService",
					"privacyUrl": "https://validation-decorator.example",
					"token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJiUzhEMi9XejV0WT0iLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RnY2EtYm9va2luZy1kZW1vLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20vYXBpL2lkZW50aXR5IiwiZXhwIjoxNjM1NDk2MzYwLCJzdWIiOiIwMDI0MWQxMS0yN2I0LTQxYWYtOWU3Ny0zNDE4YzNlY2NmZDQifQ.X0wUdET3omy3qXyOhBh1UuAUEvfYMCdapv0yVShynfZpc4yS3kH57TrPLgSqS7A9ZhbgIdCIfZwr0Chm1ELyTw",
					"consent": "Please confirm to start the DCC exchange flow. If you not confirm, the flow is aborted.",
					"subject": "Buchungsbetreff",
					"serviceProvider": "Anbietername"
				}
			"""
		)
	}
	#endif

	// MARK: - Private

	private func parseTheExtractedQRCode(url: String) {
		parser.parse(qrCode: url, completion: completion)
	}
	
	private let captureDevice: AVCaptureDevice?
	private let appConfiguration: AppConfigurationProviding
	private let healthCertificateService: HealthCertificateService
	private let parser: QRCodeParsable

}
