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
			showHUD: { [weak self] in
				DispatchQueue.main.async {
					self?.showIndicator()
				}
			},
			hideHUD: { [weak self] in
				DispatchQueue.main.async {
					self?.hideIndicator()
				}
			},
			dismiss: { [weak self] in
				DispatchQueue.main.async {
					self?.parentViewController?.dismiss(animated: true)
				}
			},
			qrCodesFound: { codes in
				Log.debug("\(codes.count) codes found", log: .fileScanner)
			},
			missingPasswordForPDF: { callback in
				self.presentPasswordAlert(callback)
			},
			failedToUnlockPDF: {
				self.presentPDFUnlockFailedAlert()
			}
		)
		
		presentActionSheet()
	}

	// MARK: - Private
	private let activityIndicatorView = FileScannerIndicatorView()
	private let duration = 0.45

	private var viewModel: FileScannerCoordinatorViewModel!
	private var parentViewController: UIViewController?
	private var dismiss: (() -> Void)?
	private var rootViewController: UIViewController?

	private enum AlertTypes {
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

	private func presentPDFUnlockFailedAlert() {
		let alert = alert(.unlockPDF)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default
			)
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

	private func presentSimpleAlert(_ type: AlertTypes) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else {
				Log.error("Failed to get strong self", log: .fileScanner)
				return
			}
			let alert = self.alertWithOK(type)
			self.parentViewController?.present(alert, animated: true)
		}
	}

	private func alert(_ type: AlertTypes) -> UIAlertController {
		return UIAlertController(
			title: type.title,
			message: type.message,
			preferredStyle: .alert
		)
	}

	private func alertWithOK(_ type: AlertTypes) -> UIAlertController {
		let alert = alert(type)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.FileScanner.buttonOk,
				style: .default,
				handler: nil
			)
		)
		return alert
	}

}
