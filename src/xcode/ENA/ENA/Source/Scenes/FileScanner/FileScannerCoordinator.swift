//
// 🦠 Corona-Warn-App
//

import UIKit

class FileScannerCoordinator {

	// MARK: - Init

	init(
		_ parentViewController: UIViewController,
		dismiss: @escaping () -> Void
	) {
		self.parentViewController = parentViewController
		self.dismiss = dismiss
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func start() {
		presentActionSheet()
	}

	// MARK: - Private

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
	}

	private func presentFilePicker() {
		Log.debug("show file picker here")
	}

}
