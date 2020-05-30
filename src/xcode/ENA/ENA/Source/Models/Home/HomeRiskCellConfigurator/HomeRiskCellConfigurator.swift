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

final class HomeRiskCellConfigurator: CollectionViewCellConfigurator {
	// MARK: Properties

	var contactAction: (() -> Void)?

	private var lastUpdateDate: Date?
	var riskLevel: RiskLevel
	private var numberRiskContacts: Int
	private var daysSinceLastExposure: Int?
	private var isLoading: Bool

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	func startLoading() {
		isLoading = true
	}

	func stopLoading() {
		isLoading = false
	}

	// MARK: Creating a Home Risk Cell Configurator

	init(
		riskLevel: RiskLevel,
		lastUpdateDate: Date?,
		numberRiskContacts: Int,
		daysSinceLastExposure: Int?,
		isLoading: Bool
	) {
		self.riskLevel = riskLevel
		self.lastUpdateDate = lastUpdateDate
		self.numberRiskContacts = numberRiskContacts
		self.daysSinceLastExposure = daysSinceLastExposure
		self.isLoading = isLoading
	}

	// MARK: Configuration

	func configure(cell: RiskCollectionViewCell) {
		var dateString: String?
		if let date = lastUpdateDate {
			dateString = HomeRiskCellConfigurator.dateFormatter.string(from: date)
		}

		let holder = HomeRiskCellPropertyHolder.propertyHolder(
			riskLevel: riskLevel,
			lastUpdateDateString: dateString,
			numberRiskContacts: numberRiskContacts,
			numberDaysLastContact: daysSinceLastExposure ?? 0,
			isLoading: isLoading
		)
		// The delegate will be called back when the cell's primary action is triggered
		cell.configure(with: holder, delegate: self)
	}
}

extension HomeRiskCellConfigurator: RiskCollectionViewCellDelegate {
	func contactButtonTapped(cell _: RiskCollectionViewCell) {
		contactAction?()
	}
}
