//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class ResetViewController: UIViewController {

	// MARK: - Init

	init(
		onResetRequest: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.onResetRequest = onResetRequest
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		scrollView.contentInset.bottom = footerView.frame.height
	}

	// MARK: - Private

	private let onResetRequest: () -> Void
	private let onDismiss: () -> Void

	@IBOutlet private weak var header1Label: DynamicTypeLabel!
	@IBOutlet private weak var description1Label: UILabel!
	@IBOutlet private weak var resetButton: ENAButton!
	@IBOutlet private weak var discardButton: ENAButton!
	@IBOutlet private weak var infoTitleLabel: DynamicTypeLabel!
	@IBOutlet private weak var infoDescriptionLabel: UILabel!
	@IBOutlet private weak var infoView: UIView!
	@IBOutlet private weak var subtitleLabel: UILabel!
	@IBOutlet private weak var subtitleLabelTopConstraint: NSLayoutConstraint!
	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var footerView: UIView!
	@IBOutlet private weak var imageView: UIImageView!

	@IBAction private func resetData(_: Any) {
		let alertController = UIAlertController(
			title: AppStrings.Reset.confirmDialogTitle,
			message: AppStrings.Reset.confirmDialogDescription,
			preferredStyle: .alert
		)

		let delete = UIAlertAction(
			title: AppStrings.Reset.confirmDialogConfirm,
			style: .destructive,
			handler: { _ in
				self.onResetRequest()
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

	@IBAction func discard(_: Any) {
		onDismiss()
	}

	private func setupView() {
		navigationItem.title = AppStrings.Reset.navigationBarTitle
		navigationItem.largeTitleDisplayMode = .always
		navigationController?.navigationBar.prefersLargeTitles = true
		
		if #available(iOS 13, *) {
			subtitleLabelTopConstraint.constant = 0
		} else {
			subtitleLabelTopConstraint.constant = 10
		}

		subtitleLabel.text = AppStrings.Reset.subtitle

		header1Label.text = AppStrings.Reset.header1
		description1Label.text = AppStrings.Reset.description1

		infoView.layer.cornerRadius = 14
		infoTitleLabel.text = AppStrings.Reset.infoTitle
		infoDescriptionLabel.text = AppStrings.Reset.infoDescription

		resetButton.setTitle(AppStrings.Reset.resetButton, for: .normal)
		discardButton.setTitle(AppStrings.Reset.discardButton, for: .normal)

		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: { [weak self] in
			self?.onDismiss()
		})

		imageView.isAccessibilityElement = true
		imageView.accessibilityLabel = AppStrings.Reset.imageDescription
		imageView.accessibilityIdentifier = AccessibilityIdentifiers.Reset.imageDescription
	}

}
