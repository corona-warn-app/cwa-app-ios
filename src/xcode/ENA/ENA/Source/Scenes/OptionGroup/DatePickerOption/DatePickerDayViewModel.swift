//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import UIKit
import Combine

class DatePickerDayViewModel {

	// MARK: - Init

	init(datePickerDay: DatePickerDay, onTapOnDate: @escaping (Date) -> Void, isSelected: Bool = false) {
		self.datePickerDay = datePickerDay
		self.onTapOnDate = onTapOnDate
		self.isSelected = isSelected

		switch datePickerDay {
		case .future(let date), .past(let date), .today(let date):
			self.date = date
		}

		updateStyle()
	}

	// MARK: - Internal

	let onTapOnDate: (Date) -> Void

	var isSelected: Bool {
		didSet {
			updateStyle()
		}
	}

	let fontSize: CGFloat = 16

	@Published var backgroundColor: UIColor = UIColor.enaColor(for: .background)
	@Published var textColor: UIColor = UIColor.enaColor(for: .textPrimary1)
	@Published var fontWeight: String = "regular"

	var dayString: String {

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "d"

		return dateFormatter.string(from: date)
	}

	func onTap() {
		switch datePickerDay {
		case .past, .today:
			onTapOnDate(date)
		case .future:
			return
		}
	}

	func selectIfSameDate(date: Date) {
		isSelected = calendar.isDate(date, inSameDayAs: self.date)
	}

	// MARK: - Private

	private let datePickerDay: DatePickerDay
	private let date: Date

	private var calendar: Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale.current

		return calendar
	}

	private func updateStyle() {
		backgroundColor = isSelected ? UIColor.enaColor(for: .tint) : UIColor.enaColor(for: .background)

		switch (datePickerDay, isSelected) {
		case (.future, _):
			textColor = .enaColor(for: .textPrimary3)
			fontWeight = "regular"
		case (.today, true):
			textColor = .enaColor(for: .textContrast)
			fontWeight = "bold"
		case (.today, false):
			textColor = .enaColor(for: .textTint)
			fontWeight = "bold"
		case (.past, true):
			textColor = .enaColor(for: .textContrast)
			fontWeight = "medium"
		case (.past, false):
			textColor = .enaColor(for: .textPrimary1)
			fontWeight = "regular"
		}
	}

}
