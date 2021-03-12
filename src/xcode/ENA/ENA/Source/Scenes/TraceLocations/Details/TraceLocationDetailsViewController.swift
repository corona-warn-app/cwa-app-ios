//
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationDetailsViewController: UIViewController, FooterViewHandling {


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

//		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.primaryButton
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			onPrintVersionButtonTap(viewModel.traceLocation)

		case .secondary:
			onDuplicateButtonTap(viewModel.traceLocation)
		}
	}

	// MARK: - Private

	private let viewModel: TraceLocationDetailsViewModel

	private let onPrintVersionButtonTap: (TraceLocation) -> Void
	private let onDuplicateButtonTap: (TraceLocation) -> Void
	private let onDismiss: () -> Void

}
