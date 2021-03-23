//
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationConfigurationViewController: UIViewController, FooterViewHandling {

	// MARK: - Init

	init(
		viewModel: TraceLocationConfigurationViewModel,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
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

		parent?.navigationItem.title = AppStrings.TraceLocations.Configuration.title
		parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem { [weak self] in
			self?.onDismiss()
		}
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		footerView?.setLoadingIndicator(true, disable: true, button: .primary)
		viewModel.save { [weak self] success in
			self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)
			if success {
				self?.onDismiss()
			}
		}

	}

	// MARK: - Private

	private let viewModel: TraceLocationConfigurationViewModel
	private let onDismiss: () -> Void

}
