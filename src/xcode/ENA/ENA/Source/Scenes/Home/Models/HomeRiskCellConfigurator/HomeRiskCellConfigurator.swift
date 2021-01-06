//
// 🦠 Corona-Warn-App
//

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
