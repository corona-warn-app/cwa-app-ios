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

		updateStyle()
	}

	// MARK: - Internal

	let onTapOnDate: (Date) -> Void

	var isSelected: Bool = false {
		didSet {
			updateStyle()
		}
	}

	@Published var textColor: UIColor = UIColor.enaColor(for: .textPrimary1)

	var dayString: String {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale.current

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "d"

		switch datePickerDay {
		case .future(let date), .past(let date), .today(let date):
			return dateFormatter.string(from: date)
		}
	}

	// MARK: - Private

	private let datePickerDay: DatePickerDay

	func updateStyle() {
		switch (datePickerDay, isSelected) {
		case (.future, _):
			textColor = .enaColor(for: .textPrimary3)
		case (_, true):
			textColor = .enaColor(for: .textContrast)
		case (.today, false):
			textColor = .enaColor(for: .textTint)
		case (.past, false):
			textColor = .enaColor(for: .textPrimary1)
		}
	}


}
