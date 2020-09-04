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

struct DatePickerOptionViewModel {

	let today: Date

	var datePickerDays: [DatePickerDay] {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale.current

		// 1 = Sunday, ..., 6 = Saturday
		let weekday = calendar.component(.weekday, from: today)
		guard let firstDayOfThisWeek = calendar.date(byAdding: .day, value: -(weekday - calendar.firstWeekday), to: today),
			let firstDayOfDatePicker = calendar.date(byAdding: .day, value: -21, to: firstDayOfThisWeek) else {
				return []
		}

		var datePickerDays = [DatePickerDay]()
		for index in 0..<28 {
			guard let date = calendar.date(byAdding: .day, value: index, to: firstDayOfDatePicker) else { return [] }

			var datePickerDay: DatePickerDay

			if calendar.isDate(date, inSameDayAs: today) {
				datePickerDay = .today(date)
			} else if date > today {
				datePickerDay = .future(date)
			} else {
				datePickerDay = .past(date)
			}

			datePickerDays.append(datePickerDay)
		}

		return datePickerDays
	}

}
