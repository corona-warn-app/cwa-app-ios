//
// 🦠 Corona-Warn-App
//

import Foundation
import PhotosUI

class FileScannerCoordinatorViewModel: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol PHPickerViewControllerDelegate

	@available(iOS 14, *)
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		dismiss?()
/*
		// each result represents a selected image
		results.forEach { result in
			let itemProvider = result.itemProvider
			guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
				return
			}
			itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  provider, error in
				guard let self = self,
					  let image = provider as? UIImage,
					  let codes = self.findQRCodes(source: "Photopicker", in: image) else {
					os_log("Looks like we have an issue reading the image")
					return
				}
				self.qrCodeModels += codes
			}
		}
 */
	}

	// MARK: - UIImagePickerControllerDelegate

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		defer {
			self.dismiss?()
		}

//		guard let image = info[.originalImage] as? UIImage,
//			  let codes = self.findQRCodes(source: "Imagepicker", in: image),
//			  !codes.isEmpty else {
//				  Log.debug("no image with qr code found")
//			return
//		}
		Log.debug("Found QR code in image", log: .fileScanner)
//		self.qrCodeModels += codes
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss?()
	}

	// MARK: - Public

	// MARK: - Internal

	var dismiss: (() -> Void)?

	var authorizationStatus: PHAuthorizationStatus {
		if #available(iOS 14, *) {
			return PHPhotoLibrary.authorizationStatus(for: .readWrite)
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


}
