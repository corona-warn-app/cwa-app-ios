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

import ExposureNotification
import UIKit

class HomeRiskCellConfigurator: CollectionViewCellConfigurator {

	let identifier = UUID()

	// MARK: Properties

	var buttonAction: (() -> Void)?

	private(set) var isLoading: Bool
	private(set) var isButtonEnabled: Bool
	private(set) var isButtonHidden: Bool
	private(set) var isCounterLabelHidden: Bool

	private(set) var startDate: Date?
	private(set) var releaseDate: Date?

	private var lastUpdateDate: Date?

	private let calendar = Calendar.current

	private static let lastUpdateDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	var lastUpdateDateString: String {
		if let lastUpdateDate = lastUpdateDate {
			return Self.lastUpdateDateFormatter.string(from: lastUpdateDate)
		} else {
			return " - "
		}
	}

	// MARK: Creating a Home Risk Cell Configurator

	init(isLoading: Bool, isButtonEnabled: Bool, isButtonHidden: Bool, isCounterLabelHidden: Bool, startDate: Date?, releaseDate: Date?, lastUpdateDate: Date?) {
		self.isLoading = isLoading
		self.isButtonEnabled = isButtonEnabled
		self.isButtonHidden = isButtonHidden
		self.isCounterLabelHidden = isCounterLabelHidden
		self.startDate = startDate
		self.releaseDate = releaseDate
		self.lastUpdateDate = lastUpdateDate
	}

	// MARK: Loading

	func startLoading() {
		isLoading = true
	}

	func stopLoading() {
		isLoading = false
	}

	// MARK: Counter

	func updateCounter(startDate: Date, releaseDate: Date) {
		self.startDate = startDate
		self.releaseDate = releaseDate
	}

	func removeCounter() {
		startDate = nil
		releaseDate = nil
	}

	// MARK: Button

	func updateButtonEnabled(_ enabled: Bool) {
		isButtonEnabled = enabled
	}

	func counterTouple() -> (minutes: Int, seconds: Int)? {
		guard let startDate = startDate else { return nil }
		guard let releaseDate = releaseDate else { return nil }
		let dateComponents = calendar.dateComponents([.minute, .second], from: startDate, to: releaseDate)
		guard let minutes = dateComponents.minute else { return nil }
		guard let seconds = dateComponents.second else { return nil }
		return (minutes: minutes, seconds: seconds)
	}

	// MARK: Configuration

	func configure(cell _: RiskCollectionViewCell) {
		fatalError("implement this method in children")
	}
}

extension HomeRiskCellConfigurator: RiskCollectionViewCellDelegate {
	func updateButtonTapped(cell _: RiskCollectionViewCell) {
		buttonAction?()
	}
}
