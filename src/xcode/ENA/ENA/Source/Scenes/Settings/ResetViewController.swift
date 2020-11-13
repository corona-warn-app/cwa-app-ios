//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol ResetDelegate: AnyObject {
	func reset()
}

final class ResetViewController: UIViewController {
	@IBOutlet var header1Label: DynamicTypeLabel!
	@IBOutlet var description1Label: UILabel!
	@IBOutlet var resetButton: ENAButton!
	@IBOutlet var discardButton: ENAButton!
	@IBOutlet var infoTitleLabel: DynamicTypeLabel!
	@IBOutlet var infoDescriptionLabel: UILabel!
	@IBOutlet var infoView: UIView!
	@IBOutlet var subtitleLabel: UILabel!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var footerView: UIView!
	@IBOutlet var imageView: UIImageView!

	weak var delegate: ResetDelegate?

	@IBAction func resetData(_: Any) {
		let alertController = UIAlertController(
			title: AppStrings.Reset.confirmDialogTitle,
			message: AppStrings.Reset.confirmDialogDescription,
			preferredStyle: .alert
		)

		let delete = UIAlertAction(
			title: AppStrings.Reset.confirmDialogConfirm,
			style: .destructive,
			handler: { _ in
				self.delegate?.reset()
				self.dismiss(animated: true, completion: nil)
			}
		)

		let cancel = UIAlertAction(
			title: AppStrings.Reset.confirmDialogCancel,
			style: .cancel
		)

		alertController.addAction(delete)
		alertController.addAction(cancel)

		present(alertController, animated: true, completion: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		scrollView.contentInset.bottom = footerView.frame.height
	}

	@IBAction func discard(_: Any) {
		dismiss(animated: true, completion: nil)
	}

	private func setupView() {
		navigationItem.title = AppStrings.Reset.navigationBarTitle

		subtitleLabel.text = AppStrings.Reset.subtitle

		header1Label.text = AppStrings.Reset.header1
		description1Label.text = AppStrings.Reset.description1

		infoView.layer.cornerRadius = 14
		infoTitleLabel.text = AppStrings.Reset.infoTitle
		infoDescriptionLabel.text = AppStrings.Reset.infoDescription

		resetButton.setTitle(AppStrings.Reset.resetButton, for: .normal)
		discardButton.setTitle(AppStrings.Reset.discardButton, for: .normal)

		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.AccessibilityLabel.close
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		imageView.isAccessibilityElement = true
		imageView.accessibilityLabel = AppStrings.Reset.imageDescription
		imageView.accessibilityIdentifier = AccessibilityIdentifiers.Reset.imageDescription
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		navigationItem.rightBarButtonItem?.image = UIImage(named: "Icons - Close")
	}
}
