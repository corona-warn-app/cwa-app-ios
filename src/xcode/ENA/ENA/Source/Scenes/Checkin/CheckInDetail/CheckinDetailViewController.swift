////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckinDetailViewController: UIViewController {

	// MARK: - Init

	init(
		_ traceLocation: TraceLocation,
		dismiss: @escaping () -> Void,
		presentCheckins: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.presentCheckins = presentCheckins
		self.viewModel = CheckinDetailViewModel(traceLocation)
		
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
	}
	
	// MARK: - Private
	
	@IBOutlet private weak var bottomCardView: UIView!
	@IBOutlet private weak var descriptionView: UIView!
	@IBOutlet private weak var logoImageView: UIImageView!
	@IBOutlet private weak var checkInForLabel: ENALabel!
	@IBOutlet private weak var activityLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var addressLabel: ENALabel!
	@IBOutlet private weak var saveToDiaryLabel: ENALabel!
	@IBOutlet private weak var automaticCheckOutLabel: ENALabel!
	@IBOutlet private weak var pickerButton: ENAButton!
	@IBOutlet private weak var pickerContainerView: UIView!
	@IBOutlet private weak var pickerSeparator: UIView!
	@IBOutlet private weak var datePickerView: UIDatePicker!
	
	
	private let viewModel: CheckinDetailViewModel
	private let dismiss: () -> Void
	private let presentCheckins: () -> Void
	private var subscriptions = Set<AnyCancellable>()
	private var selectedDuration: Int?
	private var isInitialSetup = true

	private func setupView() {
		viewModel.setupView()

		view.backgroundColor = .enaColor(for: .background)
		checkInForLabel.text = AppStrings.Checkin.Details.checkinFor
		activityLabel.text = AppStrings.Checkin.Details.activity
		saveToDiaryLabel.text = AppStrings.Checkin.Details.saveToDiary
		automaticCheckOutLabel.text = AppStrings.Checkin.Details.automaticCheckout
		logoImageView.image = logoImageView.image?.withRenderingMode(.alwaysTemplate)
		logoImageView.tintColor = .enaColor(for: .textContrast)
		addBorderAndColorToView(descriptionView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(bottomCardView, color: .enaColor(for: .hairline))

		viewModel.$descriptionLabelTitle
			.sink { [weak self] description in
				self?.descriptionLabel.text = description
			}
			.store(in: &subscriptions)
		
		viewModel.$addressLabelTitle
			.sink { [weak self] address in
				self?.addressLabel.text = address
			}
			.store(in: &subscriptions)
		
		viewModel.$initialDuration
			.sink { [weak self] duration in
				self?.selectedDuration = duration
				self?.setupPicker(with: duration ?? 0)

			}
			.store(in: &subscriptions)
	}
	
	private func setupPicker(with duration: Int) {
		datePickerView.locale = Locale(identifier: "de_DE")
		datePickerView.datePickerMode = .countDownTimer
		datePickerView.minuteInterval = 15
		datePickerView.addTarget(self, action: #selector(didSelectDuration(datePicker:)), for: .valueChanged)
	}
	
	@objc
	private func didSelectDuration(datePicker: UIDatePicker) {
		viewModel.pickerView(didSelectRow: datePicker.date.todaysMinutes)
		let components = datePicker.date.todaysMinutes.quotientAndRemainder(dividingBy: 60)
		pickerButton.setTitle(
			"\(components.quotient):\(components.remainder) " + AppStrings.Checkin.Details.hoursShortVersion,
			for: .normal
		)
	}

	private func addBorderAndColorToView(_ view: UIView, color: UIColor) {
		view.layer.borderColor = color.cgColor
		view.layer.borderWidth = 1
	}
	
	@IBAction private func showPickerButton(_ sender: Any) {
		pickerContainerView.isHidden = !pickerContainerView.isHidden
		pickerSeparator.isHidden = pickerContainerView.isHidden
		
		if !pickerContainerView.isHidden && isInitialSetup {
			isInitialSetup = false
			let components = selectedDuration?.quotientAndRemainder(dividingBy: 60)
			let date = DateComponents(calendar: Calendar.current, hour: components?.quotient, minute: components?.remainder).date ?? Date()
			datePickerView.setDate(date, animated: true)
		}
	}
	
	@IBAction private func checkInPressed(_ sender: Any) {
		viewModel.saveCheckinToDatabase()
		presentCheckins()
	}
	
	@IBAction private func cancelButtonPressed(_ sender: Any) {
		dismiss()
	}
	
	@IBAction private func switchValueChanged(_ sender: UISwitch) {
		viewModel.shouldSaveToContactJournal = sender.isOn
	}
}
