//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class EventDetailsViewController: UIViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		viewModel: EventDetailsViewModel,
		onPrintVersionButtonTap: @escaping (Event) -> Void,
		onDuplicateButtonTap: @escaping (Event) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel

		self.onPrintVersionButtonTap = onPrintVersionButtonTap
		self.onDuplicateButtonTap = onDuplicateButtonTap
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .enaColor(for: .background)

		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)

		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.primaryButton
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		onPrintVersionButtonTap(viewModel.event)
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		onDuplicateButtonTap(viewModel.event)
	}

	// MARK: - Private

	private let viewModel: EventDetailsViewModel

	private let onPrintVersionButtonTap: (Event) -> Void
	private let onDuplicateButtonTap: (Event) -> Void
	private let onDismiss: () -> Void

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.EventPlanning.EventDetails.printVersionButtonTitle
		item.isPrimaryButtonEnabled = true

		item.secondaryButtonTitle = AppStrings.EventPlanning.EventDetails.duplicateButtonTitle
		item.isSecondaryButtonEnabled = true
		item.isSecondaryButtonHidden = false

		return item
	}()

}
