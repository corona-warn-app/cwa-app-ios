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

		textFieldContainerView.layer.cornerRadius = 8
		if #available(iOS 13.0, *) {
			textFieldContainerView.layer.cornerCurve = .continuous
		}

		traceLocationTypeLabel.text = "Vereinsaktivität"
		descriptionTextField.placeholder = "Bezeichnung"
		addressTextField.placeholder = "Ort"
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


	@IBOutlet weak var traceLocationTypeLabel: ENALabel!

	@IBOutlet weak var textFieldContainerView: UIView!
	@IBOutlet weak var descriptionTextField: ENATextField!
	@IBOutlet weak var addressTextField: ENATextField!

}
