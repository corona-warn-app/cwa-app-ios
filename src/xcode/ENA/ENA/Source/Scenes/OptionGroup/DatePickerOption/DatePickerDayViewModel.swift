//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DatePickerDayViewModel {

	// MARK: - Init

	init(
		datePickerDay: DatePickerDay,
		onTapOnDate: @escaping (Date) -> Void,
		isSelected: Bool = false,
		calendar: Calendar = .gregorian()
	) {
		self.datePickerDay = datePickerDay
		self.onTapOnDate = onTapOnDate
		self.isSelected = isSelected
		self.calendar = calendar

		switch datePickerDay {
		case .moreThan21DaysAgo(let date), .upTo21DaysAgo(let date), .today(let date), .future(let date):
			self.date = date
		}

		update()
	}

	// MARK: - Internal

	var isSelected: Bool {
		didSet {
			update()
		}
	}

	let fontSize: CGFloat = 16

	@OpenCombine.Published var backgroundColor: UIColor = .enaColor(for: .background)
	@OpenCombine.Published var textColor: UIColor = .enaColor(for: .textPrimary1)
	@OpenCombine.Published var fontWeight: String = "regular"
	@OpenCombine.Published var accessibilityTraits: UIAccessibilityTraits = []

	var dayString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "d"

		return dateFormatter.string(from: date)
	}

	var accessibilityLabel: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long

		return dateFormatter.string(from: date)
	}

	var isSelectable: Bool {
		switch datePickerDay {
		case .upTo21DaysAgo, .today:
			return true
		case .moreThan21DaysAgo, .future:
			return false
		}
	}

	func onTap() {
		guard isSelectable else { return }

		onTapOnDate(date)
	}

	func selectIfSameDate(date: Date) {
		isSelected = calendar.isDate(date, inSameDayAs: self.date)
	}

	// MARK: - Private

	private let datePickerDay: DatePickerDay
	private let onTapOnDate: (Date) -> Void
	private let calendar: Calendar

	private let date: Date


	private func update() {
		backgroundColor = isSelected ? UIColor.enaColor(for: .tint) : UIColor.enaColor(for: .background)

		switch (datePickerDay, isSelected) {
		case (.future, _), (.moreThan21DaysAgo, _):
			textColor = .enaColor(for: .textPrimary3)
			fontWeight = "regular"
		case (.today, true):
			textColor = .enaColor(for: .textContrast)
			fontWeight = "bold"
		case (.today, false):
			textColor = .enaColor(for: .textTint)
			fontWeight = "bold"
		case (.upTo21DaysAgo, true):
			textColor = .enaColor(for: .textContrast)
			fontWeight = "medium"
		case (.upTo21DaysAgo, false):
			textColor = .enaColor(for: .textPrimary1)
			fontWeight = "regular"
		}

		if isSelectable {
			accessibilityTraits = isSelected ? [.button, .selected] : [.button]
		} else {
			accessibilityTraits = []
		}
	}

}
