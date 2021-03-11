//
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationDetailsViewController: UIViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		viewModel: TraceLocationDetailsViewModel,
		onPrintVersionButtonTap: @escaping (TraceLocation) -> Void,
		onDuplicateButtonTap: @escaping (TraceLocation) -> Void,
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
		onPrintVersionButtonTap(viewModel.traceLocation)
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		onDuplicateButtonTap(viewModel.traceLocation)
	}

	// MARK: - Private

	private let viewModel: TraceLocationDetailsViewModel

	private let onPrintVersionButtonTap: (TraceLocation) -> Void
	private let onDuplicateButtonTap: (TraceLocation) -> Void
	private let onDismiss: () -> Void

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.TraceLocations.Details.printVersionButtonTitle
		item.isPrimaryButtonEnabled = true

		item.secondaryButtonTitle = AppStrings.TraceLocations.Details.duplicateButtonTitle
		item.isSecondaryButtonEnabled = true
		item.isSecondaryButtonHidden = false

		return item
	}()

}
