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
		qrCodesFound: @escaping ([String]) -> Void,
		providePasswordForPDF: @escaping (@escaping (String) -> Void) -> Void,
		failedToUnlockPDF: @escaping () -> Void
	) {
		self.showHUD = showHUD
		self.hideHUD = hideHUD
		self.dismiss = dismiss
		self.qrCodesFound = qrCodesFound
		self.providePasswordForPDF = providePasswordForPDF
		self.failedToUnlockPDF = failedToUnlockPDF
	}

	// MARK: - Overrides

	// MARK: - Protocol PHPickerViewControllerDelegate

	@available(iOS 14, *)
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		defer {
			self.dismiss()
		}

		// each result represents a selected image
		results.forEach { result in
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
					Log.debug("Looks like we have an issue reading the image", log: .fileScanner)
					return
				}
				self.qrCodesFound(codes)
			}
		}
	}

	// MARK: - UIImagePickerControllerDelegate

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		defer {
			self.dismiss()
		}

		guard let image = info[.originalImage] as? UIImage,
			  let codes = self.findQRCodes(in: image),
			  !codes.isEmpty
		else {
			Log.debug("no image with qr code found", log: .fileScanner)
			return
		}
		Log.debug("Found QR code in image", log: .fileScanner)
		qrCodesFound(codes)
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
		if url.pathExtension.lowercased() == "pdf",
		   let pdfDocument = PDFDocument(url: url) {
			Log.debug("PDF picked, will scan for QR codes", log: .fileScanner)

			if pdfDocument.isEncrypted && pdfDocument.isLocked {
				Log.debug("PDF is encrypted and locked. Try to unlock, show password input screen to the user ...", log: .fileScanner)

				providePasswordForPDF { [weak self] password in
					guard let self = self else { return }

					if pdfDocument.unlock(withPassword: password) {
						Log.debug("PDF successfully unlocked.", log: .fileScanner)

						self.qrCodesFound(self.qrCodes(from: pdfDocument))
						self.dismiss()
					} else {
						Log.debug("PDF unlock failed.", log: .fileScanner)

						self.failedToUnlockPDF()
					}
				}
			} else {
				qrCodesFound(self.qrCodes(from: pdfDocument))
				self.dismiss()
			}
		} else if let image = UIImage(contentsOfFile: url.path),
				  let codes = findQRCodes(in: image) {
			Log.debug("Image picked will scan for QR codes", log: .fileScanner)
			qrCodesFound(codes)
			self.dismiss()
		} else {
			Log.debug("User picked unknown filetype for QR-Code scan.", log: .fileScanner)
		}
	}

	// MARK: - Public

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

	private func qrCodes(from pdfDocument: PDFDocument) -> [String] {
		Log.debug("PDF picked will scan for QR codes on all pages", log: .fileScanner)
		var found: [String] = []
		imagePage(from: pdfDocument).forEach { image in
			if let codes = findQRCodes(in: image) {
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

	private func findQRCodes(in image: UIImage) -> [String]? {
		guard let features = detectQRCode(image) else {
			Log.debug("no features found in image", log: .fileScanner)
			return nil
		}
		return features.compactMap { $0 as? CIQRCodeFeature }
		.compactMap { $0.messageString }
	}

	private let showHUD: () -> Void
	private let hideHUD: () -> Void
	private let dismiss: () -> Void
	private let qrCodesFound: ([String]) -> Void
	private let providePasswordForPDF: (@escaping (String) -> Void) -> Void
	private let failedToUnlockPDF: () -> Void

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

}
