////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckinDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	// MARK: - Init

	init(
		_ checkin: Checkin,
		dismiss: @escaping () -> Void,
		presentCheckins: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.presentCheckins = presentCheckins
		self.viewModel = CheckinDetailViewModel(checkin)
		
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
	
	// MARK: - Protocol UIPickerViewDelegate

	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		viewModel.pickerView(viewForRow: row, forComponent: component)
	}

	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		viewModel.pickerView(pickerView, widthForComponent: component)
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		viewModel.pickerView(didSelectRow: row, inComponent: component)
		updatePickerButtonTitle()
	}
	
	// MARK: - Protocol UIPickerViewDataSource

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		viewModel.pickerView(numberOfRowsInComponent: component)
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		viewModel.numberOfComponents
	}

	// MARK: - Private
	
	@IBOutlet private weak var pickerView: UIPickerView!
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
	
	private let viewModel: CheckinDetailViewModel
	private let dismiss: () -> Void
	private let presentCheckins: () -> Void
	private var subscriptions = Set<AnyCancellable>()

	private func setupView() {
		viewModel.setupView()

		view.backgroundColor = .enaColor(for: .background)
		checkInForLabel.text = AppStrings.Checkin.Details.checkinFor
		activityLabel.text = AppStrings.Checkin.Details.activity
		saveToDiaryLabel.text = AppStrings.Checkin.Details.saveToDiary
		automaticCheckOutLabel.text = AppStrings.Checkin.Details.automaticCheckout
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
		
		pickerView.backgroundColor = .clear

		logoImageView.image = logoImageView.image?.withRenderingMode(.alwaysTemplate)
		logoImageView.tintColor = .enaColor(for: .textContrast)
		addBorderAndColorToView(descriptionView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(bottomCardView, color: .enaColor(for: .hairline))
		pickerView.selectRow(viewModel.pickerValues.firstComponentSelectedValue ?? 0, inComponent: 0, animated: false)
		pickerView.selectRow(((viewModel.pickerValues.secondComponentSelectedValue ?? 0) / 15), inComponent: 2, animated: false)
		updatePickerButtonTitle()
	}
	
	private func addBorderAndColorToView(_ view: UIView, color: UIColor) {
		view.layer.borderColor = color.cgColor
		view.layer.borderWidth = 1
	}
	
	private func updatePickerButtonTitle() {
		let hours = viewModel.formattedValueFor(component: 0)
		let minuets = viewModel.formattedValueFor(component: 2)
		let title = "\(hours):\(minuets)" + " " + AppStrings.Checkin.Details.hoursShortVersion
		
		pickerButton.setTitle(title, for: .normal)
	}
	
	@IBAction private func showPickerButton(_ sender: Any) {
		pickerView.isHidden = !pickerView.isHidden
	}
	
	@IBAction private func checkInPressed(_ sender: Any) {
		presentCheckins()
	}
	
	@IBAction private func cancelButtonPressed(_ sender: Any) {
		dismiss()
	}
}
