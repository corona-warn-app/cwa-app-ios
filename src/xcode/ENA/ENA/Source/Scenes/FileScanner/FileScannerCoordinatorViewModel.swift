//
// 🦠 Corona-Warn-App
//

import Foundation
import PhotosUI
import PDFKit
import OpenCombine

enum FileScannerError: CaseIterable {
	case noQRCodeFound
	case fileNotReadable
	case invalidQRCode
	case photoAccess
	case passwordInput
	case unlockPDF

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
		}
	}
}

protocol FileScannerProcessing {
	var finishedPickingImage: (() -> Void)? { get set }
	var processingStarted: (() -> Void)? { get set }
	var processingFinished: ((QRCodeResult) -> Void)? { get set }
	var processingFailed: ((FileScannerError?) -> Void)? { get set }
	var missingPasswordForPDF: ((@escaping (String) -> Void) -> Void)? { get set }
}

class FileScannerCoordinatorViewModel: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, FileScannerProcessing {

	// MARK: - Init

	init(
		qrCodeDetector: QRCodeDetecting,
		qrCodeParser: QRCodeParsable
	) {
		self.qrCodeDetector = qrCodeDetector
		self.qrCodeParser = qrCodeParser
	}

	// MARK: - Protocol PHPickerViewControllerDelegate


	@available(iOS 14, *)
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		finishedPickingImageOnMain()

		// There can only be one selected image, because the selectionLimit is set to 1.
		guard let result = results.first else {
			processingFailedOnMain(nil)
			return
		}
		processItemProvider(result.itemProvider)
	}

	// MARK: - UIImagePickerControllerDelegate

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		finishedPickingImageOnMain()

		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self,
				let image = info[.originalImage] as? UIImage
			else {
				Log.debug("No image found in user selection.", log: .fileScanner)
				self?.processingFailedOnMain(.noQRCodeFound)
				return
			}

			self.scan(image)
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		finishedPickingImageOnMain()
	}

	// MARK: Protocol UIDocumentPickerDelegate

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		Log.debug("User picked files for QR-Code scan.", log: .fileScanner)
		// we can handle multiple documents here - nice
		guard let url = urls.first else {
			processingFailedOnMain(.noQRCodeFound)
			Log.debug("We need to select a least one file")
			return
		}

		if let image = UIImage(contentsOfFile: url.path) {
			scan(image)
		} else if url.pathExtension.lowercased() == "pdf",
				  let pdfDocument = PDFDocument(url: url) {
			Log.debug("PDF picked, will scan for QR codes", log: .fileScanner)

			// If the document is encryped and locked, try to unlock it.
			// The case where the document is locked, but not encrypted does not exist.
			if pdfDocument.isEncrypted && pdfDocument.isLocked {
				unlockAndScan(pdfDocument)
			} else {
				scan(pdfDocument)
			}
		} else {
			Log.debug("User picked unknown filetype for QR-Code scan.", log: .fileScanner)
			processingFailedOnMain(.fileNotReadable)
		}
	}

	// MARK: - Internal

	var finishedPickingImage: (() -> Void)?
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
		processingStartedOnMain()

		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self,
				  let codes = self.qrCodeDetector.findQRCodes(in: image)
			else {
				self?.processingFailedOnMain(.noQRCodeFound)
				Log.error("Failed to stronge self pointer")
				return
			}
			guard !codes.isEmpty else {
				self.processingFailedOnMain(.noQRCodeFound)
				return
			}

			self.findValidQRCode(from: codes) { [weak self] result in
				if let result = result {
					self?.processingFinishedOnMain(result)
				} else {
					self?.processingFailedOnMain(.noQRCodeFound)
				}
			}
		}
	}

	func unlockAndScan(_ pdfDocument: PDFDocument) {
		Log.debug("PDF is encrypted and locked. Try to unlock, show password input screen to the user ...", log: .fileScanner)

		missingPasswordForPDFOnMain { [weak self] password in
			guard let self = self else { return }

			if pdfDocument.unlock(withPassword: password) {
				Log.debug("PDF successfully unlocked.", log: .fileScanner)

				self.scan(pdfDocument)
			} else {
				Log.debug("PDF unlocking failed.", log: .fileScanner)
				self.processingFailedOnMain(.passwordInput)
			}
		}
	}

	func scan(_ pdfDocument: PDFDocument) {
		processingStartedOnMain()

		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self else {
				self?.processingFailedOnMain(.noQRCodeFound)
				Log.error("Failed to stronge self pointer")
				return
			}

			let codes = self.qrCodes(from: pdfDocument)
			self.findValidQRCode(from: codes) { [weak self] result in
				if let result = result {
					self?.processingFinishedOnMain(result)
				} else {
					self?.processingFailedOnMain(.noQRCodeFound)
				}
			}
		}
	}

	// MARK: - Private

	private let qrCodeDetector: QRCodeDetecting
	private let qrCodeParser: QRCodeParsable

	@available(iOS 14, *)
	private func processItemProvider(_ itemProvider: NSItemProvider) {
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
				self?.processingFailedOnMain(.noQRCodeFound)
				return
			}
			itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  provider, _ in
				guard let self = self,
					  let image = provider as? UIImage
				else {
					Log.debug("No image found in user selection.", log: .fileScanner)
					self?.processingFailedOnMain(.noQRCodeFound)
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
		if found.isEmpty {
			processingFailedOnMain(.noQRCodeFound)
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

		for code in codes {
			group.enter()

			qrCodeParser.parse(qrCode: code) { parseResult in
				switch parseResult {
				case .failure:
					break
				case .success(let result):
					validCodes.append(result)
				}
				group.leave()
			}
		}

		group.notify(queue: .main) { [weak self] in
			// Return first valid result.
			if let firstValidResult = validCodes.first {
				Log.debug("Found valid QR-Code from codes.", log: .fileScanner)
				completion(firstValidResult)
			} else {
				Log.debug("Didn't find a valid QR-Code from codes.", log: .fileScanner)
				self?.processingFailedOnMain(.invalidQRCode)
				completion(nil)
			}
		}
	}

	private func finishedPickingImageOnMain() {
		DispatchQueue.main.async {
			self.finishedPickingImage?()
		}
	}

	private func processingStartedOnMain() {
		DispatchQueue.main.async {
			self.processingStarted?()
		}
	}

	private func processingFinishedOnMain(_ result: QRCodeResult) {
		DispatchQueue.main.async {
			self.processingFinished?(result)
		}
	}

	private func processingFailedOnMain(_ error: FileScannerError?) {
		DispatchQueue.main.async {
			self.processingFailed?(error)
		}
	}

	private func missingPasswordForPDFOnMain(_ callback: @escaping (String) -> Void) {
		DispatchQueue.main.async {
			self.missingPasswordForPDF?(callback)
		}
	}
}
