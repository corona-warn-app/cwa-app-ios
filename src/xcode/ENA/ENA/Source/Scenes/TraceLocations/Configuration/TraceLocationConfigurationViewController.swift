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

		parent?.navigationItem.title = AppStrings.TraceLocations.Configuration.title
		parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem { [weak self] in
			self?.onDismiss()
		}

		footerView?.setBackgroundColor(.enaColor(for: .darkBackground))

		textFieldContainerView.layer.cornerRadius = 8
		temporarySettingsContainerView.layer.cornerRadius = 8
		temporaryDefaultLengthPickerBackgroundView.layer.cornerRadius = 14
		permanentSettingsContainerView.layer.cornerRadius = 8
		permanentDefaultLengthPickerBackgroundView.layer.cornerRadius = 14

		if #available(iOS 13.0, *) {
			textFieldContainerView.layer.cornerCurve = .continuous
			temporarySettingsContainerView.layer.cornerCurve = .continuous
			temporaryDefaultLengthPickerBackgroundView.layer.cornerCurve = .continuous
			permanentSettingsContainerView.layer.cornerCurve = .continuous
			permanentDefaultLengthPickerBackgroundView.layer.cornerCurve = .continuous
		}

		temporaryDefaultLengthPickerBackgroundView.layer.borderWidth = 1
		temporaryDefaultLengthPickerBackgroundView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor

		permanentDefaultLengthPickerBackgroundView.layer.borderWidth = 1
		permanentDefaultLengthPickerBackgroundView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor

		descriptionTextField.layer.cornerRadius = 0
		addressTextField.layer.cornerRadius = 0

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

	@IBOutlet private weak var traceLocationTypeLabel: ENALabel!

	@IBOutlet private weak var textFieldContainerView: UIView!
	@IBOutlet private weak var descriptionTextField: ENATextField!
	@IBOutlet private weak var addressTextField: ENATextField!

	@IBOutlet private weak var temporarySettingsContainerView: UIView!

	@IBOutlet private weak var startDateHeaderContainerView: UIView!
	@IBOutlet private weak var startDateTitleLabel: ENALabel!
	@IBOutlet private weak var startDateValueLabel: ENALabel!

	@IBOutlet private weak var startDatePickerContainerView: UIView!
	@IBOutlet private weak var startDatePicker: UIDatePicker!

	@IBOutlet private weak var endDateHeaderContainerView: UIView!
	@IBOutlet private weak var endDateTitleLabel: ENALabel!
	@IBOutlet private weak var endDateValueLabel: ENALabel!

	@IBOutlet private weak var endDatePickerContainerView: UIView!
	@IBOutlet private weak var endDatePicker: UIDatePicker!

	@IBOutlet private weak var temporaryDefaultLengthHeaderContainerView: UIView!
	@IBOutlet private weak var temporaryDefaultLengthTitleLabel: ENALabel!
	@IBOutlet private weak var temporaryDefaultLengthSwitch: UISwitch!
	@IBOutlet private weak var temporaryDefaultLengthFootnoteLabel: ENALabel!

	@IBOutlet private weak var temporaryDefaultLengthPickerContainerView: UIView!
	@IBOutlet private weak var temporaryDefaultLengthPickerBackgroundView: UIView!
	@IBOutlet private weak var temporaryDefaultLengthPicker: UIDatePicker!

	@IBOutlet private weak var permanentSettingsContainerView: UIView!

	@IBOutlet private weak var permanentDefaultLengthHeaderContainerView: UIView!
	@IBOutlet private weak var permanentDefaultLengthTitleLabel: ENALabel!
	@IBOutlet private weak var permanentDefaultValueLabel: ENALabel!
	@IBOutlet private weak var permanentDefaultLengthFootnoteLabel: ENALabel!

	@IBOutlet private weak var permanentDefaultLengthPickerContainerView: UIView!
	@IBOutlet private weak var permanentDefaultLengthPickerBackgroundView: UIView!
	@IBOutlet private weak var permanentDefaultLengthPicker: UIDatePicker!


}
