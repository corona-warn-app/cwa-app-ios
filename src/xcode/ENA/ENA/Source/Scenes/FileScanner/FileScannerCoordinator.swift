//
// 🦠 Corona-Warn-App
//

import UIKit
import PhotosUI

class FileScannerCoordinator {
	
	// MARK: - Init

	init(
		_ parentViewController: UIViewController,
		qrCodeParser: QRCodeParsable,
		qrCodeFound: @escaping (QRCodeResult) -> Void,
		noQRCodeFound: @escaping () -> Void
	) {
		self.parentViewController = parentViewController
		self.qrCodeFound = qrCodeFound
		self.qrCodeParser = qrCodeParser
		self.noQRCodeFound = noQRCodeFound
	}

	// MARK: - Internal
	
	func start() {
		self.viewModel = FileScannerCoordinatorViewModel(
			qrCodeParser: qrCodeParser,
			finishedPickingImage: { [weak self] in
				DispatchQueue.main.async {
					self?.parentViewController?.dismiss(animated: true)
				}
			},
			processingStarted: { [weak self] in
				DispatchQueue.main.async {
					self?.showIndicator()
				}
			},
			processingFinished: { [weak self] qrCodeResult in
				DispatchQueue.main.async {
					self?.qrCodeFound(qrCodeResult)
					self?.hideIndicator()
				}
			},
			processingFailed: { [weak self] alertType in
				DispatchQueue.main.async {
					self?.hideIndicator()
					if let alertType = alertType {
						self?.presentSimpleAlert(alertType)
					}
				}
			},
			missingPasswordForPDF: { [weak self] callback in
				DispatchQueue.main.async {
					self?.presentPasswordAlert(callback)
				}
			}
		)
		
		presentActionSheet()
	}

	// MARK: - Private
	private let activityIndicatorView = FileScannerIndicatorView()
	private let duration = 0.45

	private var viewModel: FileScannerCoordinatorViewModel!
	private var parentViewController: UIViewController?
	private var qrCodeFound: (QRCodeResult) -> Void
	private let qrCodeParser: QRCodeParsable
	private var noQRCodeFound: () -> Void
	private var rootViewController: UIViewController?
	
	private func presentActionSheet() {
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		sheet.addAction(photoAction)
		sheet.addAction(fileAction)
		let cancelAction = UIAlertAction(
			title: AppStrings.FileScanner.sheet.cancel,
			style: .cancel
		)
		cancelAction.accessibilityIdentifier = AccessibilityIdentifiers.FileScanner.cancelSheet
		sheet.addAction(
			cancelAction
		)
		parentViewController?.present(sheet, animated: true)
	}
	
	private lazy var photoAction: UIAlertAction = {
		let action = UIAlertAction(
			title: AppStrings.FileScanner.sheet.photos,
			style: .default
		) { [weak self] _ in
			self?.presentPhotoPicker()
		}
        action.accessibilityIdentifier = AccessibilityIdentifiers.FileScanner.photo
        return action
	}()

	private lazy var fileAction: UIAlertAction = {
		let action = UIAlertAction(
			title: AppStrings.FileScanner.sheet.documents,
			style: .default
		) { [weak self] _ in
			self?.presentFilePicker()
		}
        action.accessibilityIdentifier = AccessibilityIdentifiers.FileScanner.file
        return action
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
		let alert = alert(.photoAccess)
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

	private func presentPasswordAlert(_ completion: @escaping (String) -> Void) {
		let alert = alert(.passwordInput)
		alert.addTextField { textField in
			textField.placeholder = AppStrings.FileScanner.PasswordEntry.placeholder
			textField.isSecureTextEntry = true
		}

		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionCancel,
				style: .cancel
			)
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default
			) { _ in
				guard let passwordTextField = alert.textFields?[0] else {
					return
				}
				completion(passwordTextField.text ?? "")
			}
		)

		parentViewController?.present(alert, animated: true)
	}

	private func showIndicator() {
		guard let parentView = parentViewController?.view else {
			Log.error("Failed to get parentViewController - stop", log: .fileScanner)
			return
		}
		activityIndicatorView.alpha = 0.0
		activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(activityIndicatorView)
		NSLayoutConstraint.activate(
			[
				activityIndicatorView.topAnchor.constraint(equalTo: parentView.layoutMarginsGuide.topAnchor),
				activityIndicatorView.bottomAnchor.constraint(equalTo: parentView.layoutMarginsGuide.bottomAnchor),
				activityIndicatorView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
				activityIndicatorView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
			]
		)

		let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) { [weak self] in
			self?.activityIndicatorView.alpha = 1.0
		}
		animator.startAnimation()
	}

	private func hideIndicator() {
		let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) { [weak self] in
			self?.activityIndicatorView.alpha = 0.0
		}
		animator.addCompletion { [weak self] _ in
			self?.activityIndicatorView.removeFromSuperview()
		}
		animator.startAnimation()
	}

	private func presentSimpleAlert(_ error: FileScannerError) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else {
				Log.error("Failed to get strong self", log: .fileScanner)
				return
			}
			let alert = self.alertWithOK(error)
			self.parentViewController?.present(alert, animated: true)
		}
	}

	private func alert(_ error: FileScannerError) -> UIAlertController {
		return UIAlertController(
			title: error.title,
			message: error.message,
			preferredStyle: .alert
		)
	}

	private func alertWithOK(_ error: FileScannerError) -> UIAlertController {
		let alert = alert(error)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default,
				handler: { [weak self] _ in
					self?.noQRCodeFound()
				}
			)
		)
		return alert
	}

}
