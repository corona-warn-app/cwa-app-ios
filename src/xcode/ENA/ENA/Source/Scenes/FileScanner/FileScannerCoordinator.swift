//
// 🦠 Corona-Warn-App
//

import UIKit
import PhotosUI

class FileScannerCoordinator {

	// MARK: - Init

	init(
		_ parentViewController: UIViewController,
		dismiss: @escaping () -> Void
	) {
		self.parentViewController = parentViewController
		self.dismiss = dismiss
	}

	// MARK: - Internal

	func start() {
		self.viewModel = FileScannerCoordinatorViewModel(
			showHUD: {
				Log.debug("show HUD", log: .fileScanner)
			},
			hideHUD: {
				Log.debug("hide HUD", log: .fileScanner)
			},
			dismiss: { [weak self] in
				self?.parentViewController?.dismiss(animated: true)
			},
			qrCodesFound: { codes in
				Log.debug("\(codes.count) codes found", log: .fileScanner)
			}
		)

		presentActionSheet()
	}

	// MARK: - Private

	private var viewModel: FileScannerCoordinatorViewModel!
	private var parentViewController: UIViewController?
	private var dismiss: (() -> Void)?
	private var rootViewController: UIViewController?

	private func presentActionSheet() {
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		sheet.addAction(photoAction)
		sheet.addAction(fileAction)
		sheet.addAction(
			UIAlertAction(
				title: AppStrings.FileScanner.sheet.cancel,
				style: .cancel
			)
		)
		parentViewController?.present(sheet, animated: true)
	}

	private lazy var photoAction: UIAlertAction = {
		UIAlertAction(
			title: AppStrings.FileScanner.sheet.photos,
			style: .default
		) { [weak self] _ in
			self?.presentPhotoPicker()
		}
	}()

	private lazy var fileAction: UIAlertAction = {
		UIAlertAction(
			title: AppStrings.FileScanner.sheet.documents,
			style: .default
		) { [weak self] _ in
			self?.presentFilePicker()
		}
	}()

	private func presentPhotoPicker() {
		guard viewModel.authorizationStatus == .authorized else {
			if case .notDetermined = viewModel.authorizationStatus {
				viewModel.requestPhotoAccess { [weak self] _ in
					self?.presentPhotoPicker()
				}
			} else {
				presentPhotoAccessAlert()
			}
			return
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else {
				Log.error("Failed to get strong self", log: .fileScanner)
				return
			}
			if #available(iOS 14, *) {
				var configuration = PHPickerConfiguration(photoLibrary: .shared())
				configuration.filter = PHPickerFilter.images
				configuration.preferredAssetRepresentationMode = .current
				configuration.selectionLimit = 1

				let picker = PHPickerViewController(configuration: configuration)
				picker.delegate = self.viewModel
				self.parentViewController?.present(picker, animated: true)
			} else {
				let pickerController = UIImagePickerController()
				pickerController.delegate = self.viewModel
				pickerController.allowsEditing = false
				pickerController.mediaTypes = ["public.image"]
				pickerController.sourceType = .photoLibrary
				self.parentViewController?.present(pickerController, animated: true)
			}
		}
	}

	private func presentFilePicker() {
		let pickerViewController: UIDocumentPickerViewController
		if #available(iOS 14.0, *) {
			pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf], asCopy: true)
		} else {
			pickerViewController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
		}
		pickerViewController.delegate = viewModel
		parentViewController?.present(pickerViewController, animated: true)
	}

	private func presentPhotoAccessAlert() {
		let alert = UIAlertController(
			title: AppStrings.FileScanner.AccessError.title,
			message: AppStrings.FileScanner.AccessError.message,
			preferredStyle: .alert)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.FileScanner.AccessError.cancel,
				style: .cancel
			)
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.FileScanner.AccessError.settings,
				style: .default,
				handler: { _ in
					LinkHelper.open(urlString: UIApplication.openSettingsURLString)
				}
			)
		)
		parentViewController?.present(alert, animated: true)
	}

}
