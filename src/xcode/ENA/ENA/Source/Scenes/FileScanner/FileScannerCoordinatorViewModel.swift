//
// 🦠 Corona-Warn-App
//

import Foundation
import PhotosUI
import PDFKit
import OpenCombine

enum FileScannerError {
	case noQRCodeFound
	case fileNotReadable
	case invalidQRCode
	case photoAccess
	case passwordInput
	case unlockPDF
	case alreadyRegistered
	case qrCodeParserError(QRCodeParserError)

	var title: String {
		switch self {
		case .noQRCodeFound:
			return AppStrings.FileScanner.NoQRCodeFound.title
		case .fileNotReadable:
			return AppStrings.FileScanner.FileNotReadable.title
		case .invalidQRCode:
			return AppStrings.FileScanner.InvalidQRCodeError.title
		case .photoAccess:
			return AppStrings.FileScanner.AccessError.title
		case .passwordInput:
			return AppStrings.FileScanner.PasswordEntry.title
		case .unlockPDF:
			return AppStrings.FileScanner.PasswordError.title
		case .alreadyRegistered:
			return AppStrings.FileScanner.AlreadyRegistered.title
		case .qrCodeParserError:
			return ""
		}
	}

	var message: String {
		switch self {
		case .noQRCodeFound:
			return AppStrings.FileScanner.NoQRCodeFound.message
		case .fileNotReadable:
			return AppStrings.FileScanner.FileNotReadable.message
		case .invalidQRCode:
			return AppStrings.FileScanner.InvalidQRCodeError.message
		case .photoAccess:
			return AppStrings.FileScanner.AccessError.message
		case .passwordInput:
			return AppStrings.FileScanner.PasswordEntry.message
		case .unlockPDF:
			return AppStrings.FileScanner.PasswordError.message
		case .alreadyRegistered:
			return AppStrings.FileScanner.AlreadyRegistered.message
		case .qrCodeParserError:
			return ""
		}
	}
}

protocol FileScannerProcessing {
	var processingStarted: (() -> Void)? { get set }
	var processingFinished: ((QRCodeResult) -> Void)? { get set }
	var processingFailed: ((FileScannerError?) -> Void)? { get set }
	var missingPasswordForPDF: ((@escaping (String) -> Void) -> Void)? { get set }

	var authorizationStatus: PHAuthorizationStatus { get }

	func requestPhotoAccess(_ completion: @escaping (PHAuthorizationStatus) -> Void)
	func scan(_ image: UIImage)
	func scan(_ pdfDocument: PDFDocument)
	func unlockAndScan(_ pdfDocument: PDFDocument)
	@available(iOS 14, *)
	func processItemProvider(_ itemProvider: NSItemProvider)
}

class FileScannerCoordinatorViewModel: FileScannerProcessing {

	// MARK: - Init

	init(
		qrCodeDetector: QRCodeDetecting,
		qrCodeParser: QRCodeParsable,
		queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
	) {
		self.qrCodeDetector = qrCodeDetector
		self.qrCodeParser = qrCodeParser
		self.queue = queue
	}

	// MARK: - Internal

	var processingStarted: (() -> Void)?
	var processingFinished: ((QRCodeResult) -> Void)?
	var processingFailed: ((FileScannerError?) -> Void)?
	var missingPasswordForPDF: ((@escaping (String) -> Void) -> Void)?

	var authorizationStatus: PHAuthorizationStatus {
		if #available(iOS 14, *) {
			let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
			// a special case on iOS 14 (and above) that won't impact anything at the moment
			if case .limited = status {
				return .authorized
			} else {
				return status
			}
		} else {
			return PHPhotoLibrary.authorizationStatus()
		}
	}

	func requestPhotoAccess(_ completion: @escaping (PHAuthorizationStatus) -> Void) {
		if #available(iOS 14, *) {
			PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: completion)
		} else {
			PHPhotoLibrary.requestAuthorization(completion)
		}
	}

	func scan(_ image: UIImage) {
		processingStartedOnQueue()

		queue.async { [weak self] in
			guard let self = self,
				  let codes = self.qrCodeDetector.findQRCodes(in: image)
			else {
				self?.processingFailedOnQueue(.noQRCodeFound)
				Log.error("Failed to stronge self pointer")
				return
			}
			guard !codes.isEmpty else {
				self.processingFailedOnQueue(.noQRCodeFound)
				return
			}

			self.findValidQRCode(from: codes) { [weak self] result in
				if let result = result {
					self?.processingFinishedOnQueue(result)
				} else {
					self?.processingFailedOnQueue(.noQRCodeFound)
				}
			}
		}
	}

	func unlockAndScan(_ pdfDocument: PDFDocument) {
		Log.debug("PDF is encrypted and locked. Try to unlock, show password input screen to the user ...", log: .fileScanner)

		missingPasswordForPDFOnQueue { [weak self] password in
			guard let self = self else { return }

			if pdfDocument.unlock(withPassword: password) {
				Log.debug("PDF successfully unlocked.", log: .fileScanner)

				self.scan(pdfDocument)
			} else {
				Log.debug("PDF unlocking failed.", log: .fileScanner)
				self.processingFailedOnQueue(.passwordInput)
			}
		}
	}

	func scan(_ pdfDocument: PDFDocument) {
		processingStartedOnQueue()

		queue.async { [weak self] in
			guard let self = self else {
				self?.processingFailedOnQueue(.noQRCodeFound)
				Log.error("Failed to strong self pointer")
				return
			}

			let codes = self.qrCodes(from: pdfDocument)
			if codes.isEmpty {
				self.processingFailedOnQueue(.noQRCodeFound)
				return
			}

			self.findValidQRCode(from: codes) { [weak self] result in
				if let result = result {
					self?.processingFinishedOnQueue(result)
				} else {
					self?.processingFailedOnQueue(.noQRCodeFound)
				}
			}
		}
	}

	// MARK: - Private

	private let qrCodeDetector: QRCodeDetecting
	private let qrCodeParser: QRCodeParsable
	private let queue: DispatchQueue

	@available(iOS 14, *)
	func processItemProvider(_ itemProvider: NSItemProvider) {
		queue.async { [weak self] in
			guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
				self?.processingFailedOnQueue(.noQRCodeFound)
				return
			}
			itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  provider, _ in
				guard let self = self,
					  let image = provider as? UIImage
				else {
					Log.debug("No image found in user selection.", log: .fileScanner)
					self?.processingFailedOnQueue(.noQRCodeFound)
					return
				}

				self.scan(image)
			}
		}
	}

	private func qrCodes(from pdfDocument: PDFDocument) -> [String] {
		Log.debug("PDF picked, will scan for QR codes on all pages", log: .fileScanner)
		var found: [String] = []
		imagePage(from: pdfDocument).forEach { [weak self] image in
			if let codes = self?.qrCodeDetector.findQRCodes(in: image) {
				found.append(contentsOf: codes)
			}
		}
		return found
	}

	private func imagePage(from document: PDFDocument) -> [UIImage] {
		var images = [UIImage]()
		for pageIndex in 0..<document.pageCount {
			guard let page = document.page(at: pageIndex) else {
				Log.debug("can't find page in PDF file", log: .fileScanner)
				continue
			}

			let scale = UIScreen.main.scale
			let size = page.bounds(for: .mediaBox).size
			let scaledSize = size.applying(CGAffineTransform(scaleX: scale, y: scale))
			let thumb = page.thumbnail(of: scaledSize, for: .mediaBox)
			images.append(thumb)
		}
		return images
	}

	private func findValidQRCode(from codes: [String], completion: @escaping (QRCodeResult?) -> Void) {
		Log.debug("Try to find a valid QR-Code from codes.", log: .fileScanner)

		let group = DispatchGroup()
		var validCodes = [QRCodeResult]()
		var errors = [QRCodeParserError]()

		for code in codes {
			group.enter()

			qrCodeParser.parse(qrCode: code) { parseResult in
				switch parseResult {
				case .failure(let qrCodeParseError):
					errors.append(qrCodeParseError)
				case .success(let result):
					validCodes.append(result)
				}

				group.leave()
			}
		}

		group.notify(queue: queue) { [weak self] in
			// Return first valid result.
			if let firstValidResult = validCodes.first {
				Log.debug("Found valid QR-Code from codes.", log: .fileScanner)
				completion(firstValidResult)
			} else {
				Log.debug("Didn't find a valid QR-Code from codes.", log: .fileScanner)
				if let parseError = errors.first {
					self?.processingFailedOnQueue(.qrCodeParserError(parseError))
				}
				completion(nil)
			}
		}
	}

	private func processingStartedOnQueue() {
		DispatchQueue.main.async {
			self.processingStarted?()
		}
	}

	private func processingFinishedOnQueue(_ result: QRCodeResult) {
		DispatchQueue.main.async {
			self.processingFinished?(result)
		}
	}

	private func processingFailedOnQueue(_ error: FileScannerError?) {
		DispatchQueue.main.async {
			self.processingFailed?(error)
		}
	}
	
	private func missingPasswordForPDFOnQueue(_ callback: @escaping (String) -> Void) {
		DispatchQueue.main.async {
			self.missingPasswordForPDF?(callback)
		}
	}
}
