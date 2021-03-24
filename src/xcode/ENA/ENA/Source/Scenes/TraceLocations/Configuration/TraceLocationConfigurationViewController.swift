//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

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

		setUpLayout()
		setUpGestureRecognizers()
		setUpBindings()

		traceLocationTypeLabel.text = viewModel.traceLocationTypeTitle
		temporarySettingsContainerView.isHidden = viewModel.temporarySettingsContainerIsHidden
		permanentSettingsContainerView.isHidden = viewModel.permanentSettingsContainerIsHidden

		descriptionTextField.placeholder = AppStrings.TraceLocations.Configuration.descriptionPlaceholder
		addressTextField.placeholder = AppStrings.TraceLocations.Configuration.addressPlaceholder

		startDateTitleLabel.text = AppStrings.TraceLocations.Configuration.startDateTitle
		endDateTitleLabel.text = AppStrings.TraceLocations.Configuration.endDateTitle

		temporaryDefaultLengthTitleLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthTitle
		temporaryDefaultLengthFootnoteLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthFootnote
		permanentDefaultLengthTitleLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthTitle
		permanentDefaultLengthFootnoteLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthFootnote

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

	private var subscriptions = Set<AnyCancellable>()

	@IBOutlet private weak var traceLocationTypeLabel: ENALabel!

	@IBOutlet private weak var textFieldContainerView: UIView!
	@IBOutlet private weak var descriptionTextField: ENATextField!
	@IBOutlet private weak var addressTextField: ENATextField!

	// MARK: Temporary Trace Location Settings

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

	// MARK: Permanent Trace Location Settings

	@IBOutlet private weak var permanentSettingsContainerView: UIView!

	@IBOutlet private weak var permanentDefaultLengthHeaderContainerView: UIView!
	@IBOutlet private weak var permanentDefaultLengthTitleLabel: ENALabel!
	@IBOutlet private weak var permanentDefaultValueLabel: ENALabel!
	@IBOutlet private weak var permanentDefaultLengthFootnoteLabel: ENALabel!

	@IBOutlet private weak var permanentDefaultLengthPickerContainerView: UIView!
	@IBOutlet private weak var permanentDefaultLengthPickerBackgroundView: UIView!
	@IBOutlet private weak var permanentDefaultLengthPicker: UIDatePicker!

	private func setUpLayout() {
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
	}

	private func setUpGestureRecognizers() {
		let startDateGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startDateHeaderTapped))
		startDateHeaderContainerView.addGestureRecognizer(startDateGestureRecognizer)

		let endDateGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endDateHeaderTapped))
		endDateHeaderContainerView.addGestureRecognizer(endDateGestureRecognizer)

		let temporaryDefaultLengthGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(temporaryDefaultLengthHeaderTapped))
		temporaryDefaultLengthHeaderContainerView.addGestureRecognizer(temporaryDefaultLengthGestureRecognizer)

		let permanentDefaultLengthGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(permanentDefaultLengthHeaderTapped))
		permanentDefaultLengthHeaderContainerView.addGestureRecognizer(permanentDefaultLengthGestureRecognizer)
	}

	@objc
	private func startDateHeaderTapped() {
		viewModel.startDateHeaderTapped()
	}

	@objc
	private func endDateHeaderTapped() {
		viewModel.endDateHeaderTapped()
	}

	@objc
	private func temporaryDefaultLengthHeaderTapped() {
		viewModel.temporaryDefaultLengthHeaderTapped()
	}

	@objc
	private func permanentDefaultLengthHeaderTapped() {
		viewModel.permanentDefaultLengthHeaderTapped()
	}

	private func setUpBindings() {
		viewModel.$description
			.assign(to: \.text, on: descriptionTextField)
			.store(in: &subscriptions)

		viewModel.$address
			.assign(to: \.text, on: addressTextField)
			.store(in: &subscriptions)

		viewModel.$startDatePickerIsHidden
			.sink { [weak self] isHidden in
				UIView.animate(withDuration: 0.25) {
					self?.startDatePickerContainerView.isHidden = isHidden
				}
			}
			.store(in: &subscriptions)

		viewModel.$endDatePickerIsHidden
			.sink { [weak self] isHidden in
//				UIView.animate(withDuration: 0.25) {
					self?.endDatePickerContainerView.isHidden = isHidden
//				}
			}
			.store(in: &subscriptions)

		viewModel.$temporaryDefaultLengthPickerIsHidden
			.sink { [weak self] isHidden in
				UIView.animate(withDuration: 0.25) {
					self?.temporaryDefaultLengthPickerContainerView.isHidden = isHidden
				}
			}
			.store(in: &subscriptions)

		viewModel.$permanentDefaultLengthPickerIsHidden
			.sink { [weak self] isHidden in
				UIView.animate(withDuration: 0.25) {
					self?.permanentDefaultLengthPickerContainerView.isHidden = isHidden
				}
			}
			.store(in: &subscriptions)
	}

}
