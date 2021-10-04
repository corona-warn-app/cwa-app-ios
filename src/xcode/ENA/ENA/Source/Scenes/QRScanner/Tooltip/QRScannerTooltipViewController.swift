//
// 🦠 Corona-Warn-App
//

import UIKit

class QRScannerTooltipViewController: UIViewController, UIPopoverPresentationControllerDelegate {

	// MARK: - Init

	init(
		onDismiss: @escaping () -> Void
	) {
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)

		modalPresentationStyle = .popover
		popoverPresentationController?.delegate = self
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		titleLabel.text = AppStrings.UniversalQRScanner.Tooltip.title
		descriptionLabel.text = AppStrings.UniversalQRScanner.Tooltip.description

		closeButton.accessibilityLabel = AppStrings.AccessibilityLabel.close
		closeButton.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}

	// MARK: - Protocol UIPopoverPresentationControllerDelegate

	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return  .none
	}

	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		onDismiss()
	}

	// MARK: - Private

	private let onDismiss: () -> Void

	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var titleLabel: ENALabel!
	@IBOutlet weak var descriptionLabel: ENALabel!

	@IBAction func dismissButtonTapped(_ sender: Any) {
		onDismiss()
	}

}
