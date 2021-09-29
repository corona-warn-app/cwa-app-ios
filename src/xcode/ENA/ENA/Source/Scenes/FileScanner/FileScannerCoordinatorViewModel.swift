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
		qrCodeParser: QRCodeParsable
	) {
		self.showHUD = showHUD
		self.hideHUD = hideHUD
		self.dismiss = dismiss
		self.qrCodeFound = qrCodeFound
		self.qrCodeParser = qrCodeParser
	}

	// MARK: - Protocol PHPickerViewControllerDelegate

	@available(iOS 14, *)
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

		// each result represents a selected image
		results.forEach { result in
			let itemProvider = result.itemProvider
			guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
				Log.debug("Looks like we have an issue reading the image", log: .fileScanner)
				self.dismiss()
				return
			}
			itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  provider, _ in
				guard let self = self else { return }

				guard let image = provider as? UIImage,
					  let codes = self.findQRCodes(in: image),
					  !codes.isEmpty
				else {
					self.dismiss()
					return
				}
				Log.debug("Found codes in image.", log: .fileScanner)
				self.findValidQRCode(from: codes) { result in
					self.qrCodeFound(result)
					self.dismiss()
				}
			}
		}
	}

	// MARK: - UIImagePickerControllerDelegate

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		guard let image = info[.originalImage] as? UIImage,
			  let codes = self.findQRCodes(in: image),
			  !codes.isEmpty
		else {
			Log.debug("no image with qr code found", log: .fileScanner)
			self.dismiss()
			return
		}

		Log.debug("Found QR codes in image", log: .fileScanner)

		findValidQRCode(from: codes) { [weak self] result in
			self?.qrCodeFound(result)
			self?.dismiss()
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss()
	}

	// MARK: Protocol UIDocumentPickerDelegate

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

		// we can handle multiple documents here - nice
		guard let url = urls.first else {
			Log.debug("We need to select a least one file")
			self.dismiss()
			return
		}
		if url.pathExtension.lowercased() == "pdf",
		   let pdfDocument = PDFDocument(url: url) {
			Log.debug("PDF picked will scan for QR codes on all pages", log: .fileScanner)
			var codes: [String] = []
			imagePage(from: pdfDocument).forEach { image in
				if let _codes = findQRCodes(in: image) {
					codes.append(contentsOf: _codes)
				}
			}
			findValidQRCode(from: codes) { [weak self] result in
				self?.qrCodeFound(result)
				self?.dismiss()
			}
		} else if let image = UIImage(contentsOfFile: url.path),
				  let codes = findQRCodes(in: image) {
			Log.debug("Image picked will scan for QR codes", log: .fileScanner)
			findValidQRCode(from: codes) { [weak self] result in
				self?.qrCodeFound(result)
				self?.dismiss()
			}
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

	private let showHUD: () -> Void
	private let hideHUD: () -> Void
	private let dismiss: () -> Void
	private let qrCodeFound: (QRCodeResult?) -> Void
	private let qrCodeParser: QRCodeParsable

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
		var codeResult: QRCodeResult?

		for code in codes {
			group.enter()

			qrCodeParser.parse(qrCode: code) { parseResult in
				switch parseResult {
				case .failure:
					break
				case .success(let result):
					Log.debug("Found valid QR-Code from codes.", log: .fileScanner)
					codeResult = result
				}
				group.leave()
			}
		}

		group.notify(queue: .main) {
			if codeResult == nil {
				Log.debug("Didn't find a valid QR-Code from codes.", log: .fileScanner)
			}
			return completion(codeResult)
		}
	}
}
