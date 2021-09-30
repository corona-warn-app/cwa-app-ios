//
// 🦠 Corona-Warn-App
//

import Foundation
import PhotosUI
import PDFKit
import OpenCombine

class FileScannerCoordinatorViewModel: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

	// MARK: - Init

	init(
		showHUD: @escaping () -> Void,
		hideHUD: @escaping () -> Void,
		dismiss: @escaping () -> Void,
		qrCodeFound: @escaping (QRCodeResult?) -> Void,
		qrCodeParser: QRCodeParsable,
		missingPasswordForPDF: @escaping (@escaping (String) -> Void) -> Void,
		failedToUnlockPDF: @escaping () -> Void,
		presentSimpleAlert: @escaping (FileScannerCoordinator.AlertTypes) -> Void
	) {
		self.showHUD = showHUD
		self.hideHUD = hideHUD
		self.dismiss = dismiss
		self.qrCodeFound = qrCodeFound
		self.qrCodeParser = qrCodeParser
		self.missingPasswordForPDF = missingPasswordForPDF
		self.failedToUnlockPDF = failedToUnlockPDF
		self.presentSimpleAlert = presentSimpleAlert
	}

	// MARK: - Protocol PHPickerViewControllerDelegate

	@available(iOS 14, *)
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		dismiss()
		showHUD()

		DispatchQueue.global(qos: .background).async { [weak self] in
			// There can only be one selected image, because the selectionLimit is set to 1.
			guard let result = results.first else {
				self?.dismiss()
				return
			}

			let itemProvider = result.itemProvider
			guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
				return
			}
			itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  provider, _ in
				guard let self = self,
					  let image = provider as? UIImage,
					  let codes = self.findQRCodes(in: image),
					  !codes.isEmpty
				else {
					self?.presentSimpleAlert(.noQRCodeFound)
					self?.hideHUD()
					return
				}

				Log.debug("Found codes in image.", log: .fileScanner)
				self.findValidQRCode(from: codes) { [weak self] result in
					self?.qrCodeFound(result)
				}
			}
		}
	}

	// MARK: - UIImagePickerControllerDelegate

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		dismiss()
		showHUD()

		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let image = info[.originalImage] as? UIImage,
				  let codes = self?.findQRCodes(in: image),
				  !codes.isEmpty
			else {
				Log.debug("no image with qr code found", log: .fileScanner)
				self?.presentSimpleAlert(.noQRCodeFound)
				self?.hideHUD()
				return
			}

			Log.debug("Found QR codes in image", log: .fileScanner)

			self?.findValidQRCode(from: codes) { [weak self] result in
				self?.qrCodeFound(result)
			}
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss()
	}

	// MARK: Protocol UIDocumentPickerDelegate

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		Log.debug("User picked files for QR-Code scan.", log: .fileScanner)
		// we can handle multiple documents here - nice
		guard let url = urls.first else {
			Log.debug("We need to select a least one file")
			return
		}

		if let image = UIImage(contentsOfFile: url.path) {
			scanImageFile(image)
		} else if url.pathExtension.lowercased() == "pdf",
				  let pdfDocument = PDFDocument(url: url) {
			Log.debug("PDF picked, will scan for QR codes", log: .fileScanner)

			// If the document is encryped and locked, try to unlock it.
			// The case where the document is locked, but not encrypted does not exist.
			if pdfDocument.isEncrypted && pdfDocument.isLocked {
				Log.debug("PDF is encrypted and locked. Try to unlock, show password input screen to the user ...", log: .fileScanner)

				missingPasswordForPDF { [weak self] password in
					guard let self = self else { return }
					if pdfDocument.unlock(withPassword: password) {
						Log.debug("PDF successfully unlocked.", log: .fileScanner)

						self.scanPDFDocument(pdfDocument)
					} else {
						Log.debug("PDF unlocking failed.", log: .fileScanner)
						self.failedToUnlockPDF()
					}
				}
			} else {
				scanPDFDocument(pdfDocument)
			}
		} else {
			Log.debug("User picked unknown filetype for QR-Code scan.", log: .fileScanner)
		}
	}

	// MARK: - Internal

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

	// MARK: - Private

	private let dismiss: () -> Void
	private let showHUD: () -> Void
	private let hideHUD: () -> Void
	private let qrCodeFound: (QRCodeResult?) -> Void
	private let qrCodeParser: QRCodeParsable
	private let missingPasswordForPDF: (@escaping (String) -> Void) -> Void
	private let failedToUnlockPDF: () -> Void
	private let presentSimpleAlert: (FileScannerCoordinator.AlertTypes) -> Void

	private func scanPDFDocument(_ pdfDocument: PDFDocument) {
		showHUD()
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self else {
				Log.error("Failed to stronge self pointer")
				return
			}

			let codes = self.qrCodes(from: pdfDocument)
			self.findValidQRCode(from: codes) { [weak self] result in
				self?.qrCodeFound(result)
				self?.hideHUD()
//				self?.dismiss()
			}
		}
	}

	private func scanImageFile(_ image: UIImage) {
		showHUD()
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self,
				  let codes = self.findQRCodes(in: image)
			else {
				Log.error("Failed to stronge self pointer")
				return
			}
			guard !codes.isEmpty else {
				self.presentSimpleAlert(.noQRCodeFound)
				self.hideHUD()
				return
			}

			self.findValidQRCode(from: codes) { [weak self] result in
				self?.qrCodeFound(result)
				self?.hideHUD()
			}
		}
	}

	private func qrCodes(from pdfDocument: PDFDocument) -> [String] {
		Log.debug("PDF picked, will scan for QR codes on all pages", log: .fileScanner)
		var found: [String] = []
		imagePage(from: pdfDocument).forEach { image in
			if let codes = findQRCodes(in: image) {
				found.append(contentsOf: codes)
			}
		}
		if found.isEmpty {
			presentSimpleAlert(.noQRCodeFound)
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

	private func findQRCodes(in image: UIImage) -> [String]? {
		guard let features = detectQRCode(image) else {
			Log.debug("no features found in image", log: .fileScanner)
			return nil
		}
		let codes = features.compactMap { $0 as? CIQRCodeFeature }
		.compactMap { $0.messageString }

		return codes
	}

	private func detectQRCode(_ image: UIImage) -> [CIFeature]? {
		guard let ciImage = CIImage(image: image) else {
			return nil
		}
		let context = CIContext()
		// we can try to use CIDetectorAccuracyLow to speedup things a bit here
		let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
		let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
		let features = qrDetector?.features(in: ciImage, options: options)
		return features
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
				self?.presentSimpleAlert(.invalidQRCode)
				completion(nil)
			}
		}
	}
}
