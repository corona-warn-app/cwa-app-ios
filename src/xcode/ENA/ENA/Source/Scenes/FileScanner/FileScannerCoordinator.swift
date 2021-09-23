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
		self.viewModel = FileScannerCoordinatorViewModel()
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func start() {
		presentActionSheet()
	}

	// MARK: - Private

	private let viewModel: FileScannerCoordinatorViewModel

	private var parentViewController: UIViewController?
	private var dismiss: (() -> Void)?
	private var rootViewController: UIViewController?

	private func presentActionSheet() {
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		sheet.addAction(photoAction)
		sheet.addAction(fileAction)
		sheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
		parentViewController?.present(sheet, animated: true)
	}

	private lazy var photoAction: UIAlertAction = {
		UIAlertAction(title: "Fotos", style: .default) { [weak self] _ in
			self?.presentPhotoPicker()
		}
	}()

	private lazy var fileAction: UIAlertAction = {
		UIAlertAction(title: "Files", style: .default) { [weak self] _ in
			self?.presentFilePicker()
		}
	}()

	private func presentPhotoPicker() {
		Log.debug("show photo picker here")
		if #available(iOS 14, *) {
			var configuration = PHPickerConfiguration(photoLibrary: .shared())
			configuration.filter = PHPickerFilter.images
			configuration.preferredAssetRepresentationMode = .current
			configuration.selectionLimit = 1

			let picker = PHPickerViewController(configuration: configuration)
			picker.delegate = viewModel
			viewModel.dismiss = { [weak self] in
				self?.parentViewController?.dismiss(animated: true)
			}
			parentViewController?.present(picker, animated: true)
		} else {
			let pickerController = UIImagePickerController()
			pickerController.delegate = viewModel
			pickerController.allowsEditing = false
			pickerController.mediaTypes = ["public.image"]
			pickerController.sourceType = .photoLibrary
			viewModel.dismiss = { [weak self] in
				self?.parentViewController?.dismiss(animated: true)
			}
			parentViewController?.present(pickerController, animated: true)
		}
	}

	private func presentFilePicker() {
		Log.debug("show file picker here")
	}

}
