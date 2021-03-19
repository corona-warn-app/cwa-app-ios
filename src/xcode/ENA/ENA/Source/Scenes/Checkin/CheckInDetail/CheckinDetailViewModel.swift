////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class CheckinDetailViewModel {

	// MARK: - Init
	init(
		_ checkin: Checkin
	) {
		self.checkin = checkin
		let components: Set<Calendar.Component> = [.minute, .hour]
		let eventDuration = Calendar.current.dateComponents(
			components,
			from: checkin.traceLocationStartDate ?? Date(),
			to: checkin.traceLocationEndDate ?? Date()
		)
		pickerValues = TwoComponentsIntegerPicker(
			firstComponentSelectedValue: eventDuration.hour,
			secondComponentSelectedValue: eventDuration.minute,
			firstComponentValues: Array(0...23),
			secondComponentValues: [0, 15, 30, 45]
		)
	}
	
	// MARK: - Internal
	
	let numberOfComponents = 4
	
	@OpenCombine.Published var descriptionLabelTitle: String?
	@OpenCombine.Published var addressLabelTitle: String?

	func pickerView(viewForRow row: Int, forComponent component: Int) -> UIView {
		let pickerLabel = ENALabel()
		let weight: UIFont.Weight = (component == 0 || component == 2) ? .regular : .semibold
		pickerLabel.font = .enaFont(for: .subheadline, weight: weight, italic: false)
		pickerLabel.adjustsFontForContentSizeCategory = false
		
		switch component {
		case 0:
			pickerLabel.text = "\(pickerValues.firstComponentValues[row])"
			pickerLabel.textAlignment = .center
		case 1:
			pickerLabel.text = AppStrings.Checkin.Details.hours
			pickerLabel.textAlignment = .left
		case 2:
			pickerLabel.text = "\(pickerValues.secondComponentValues[row])"
			pickerLabel.textAlignment = .center
		case 3:
			pickerLabel.text = AppStrings.Checkin.Details.minutes
			pickerLabel.textAlignment = .left
		default:
			pickerLabel.text = ""
		}
		return pickerLabel
	}
	
	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		switch component {
		case 0, 2:
			return pickerView.bounds.width * 0.15
		case 1, 3:
			return pickerView.bounds.width * 0.35
		default:
			return 0
		}
	}
	
	func pickerView(didSelectRow row: Int, inComponent component: Int) {
		switch component {
		case 0:
			pickerValues.firstComponentSelectedValue = pickerValues.firstComponentValues[row]
		case 2:
			pickerValues.secondComponentSelectedValue = pickerValues.secondComponentValues[row]
		default:
			break
		}
	}
	
	func pickerView(numberOfRowsInComponent component: Int) -> Int {
		switch component {
		case 0:
			return pickerValues.firstComponentValues.count
		case 1:
			return 1
		case 2:
			return pickerValues.secondComponentValues.count
		case 3:
			return 1
		default:
			return 0
		}
	}
	
	func setupView() {
		descriptionLabelTitle = checkin.traceLocationDescription
		addressLabelTitle = checkin.traceLocationAddress
	}

	func formattedValueFor(component: Int) -> String {
		let intValue: Int
		
		switch component {
		case 0:
			intValue = pickerValues.firstComponentSelectedValue ?? 0
		case 2:
			intValue = pickerValues.secondComponentSelectedValue ?? 0
		default:
			return "00"
		}
		
		if intValue < 10 {
			return "0" + String(describing: intValue)
		} else {
			return String(describing: intValue)
		}
	}

	// MARK: - Private
	
	private let checkin: Checkin
	private(set) var pickerValues: TwoComponentsIntegerPicker
}
