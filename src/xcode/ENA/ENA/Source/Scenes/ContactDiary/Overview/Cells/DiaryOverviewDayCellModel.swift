////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DiaryOverviewDayCellModel {

	// MARK: - Init

	init(
		_ diaryDay: DiaryDay,
		historyExposure: HistoryExposure
	) {
		self.diaryDay = diaryDay
		self.historyExposure = historyExposure
	}

	// MARK: - Public

	// MARK: - Internal

	let historyExposure: HistoryExposure

	func entryDetailTextFor(personEncounter: ContactPersonEncounter) -> String {
		var detailComponents = [String]()
		detailComponents.append(personEncounter.duration.description)
		detailComponents.append(personEncounter.maskSituation.description)
		detailComponents.append(personEncounter.setting.description)

		// Filter empty strings.
		detailComponents = detailComponents.filter { $0 != "" }

		return detailComponents.joined(separator: ", ")
	}

	func entryDetailTextFor(locationVisit: LocationVisit) -> String {
		guard locationVisit.durationInMinutes > 0 else {
			return ""
		}

		let dateComponents = DateComponents(minute: locationVisit.durationInMinutes)
		let timeString = dateComponentsFormatter.string(from: dateComponents) ?? ""
		return timeString + " \(AppStrings.ContactDiary.LocationVisit.abbreviationHours)"
	}

	var hideExposureHistory: Bool {
		switch historyExposure {
		case .none:
			return true
		case .encounter:
			return false
		}
	}

	var exposureHistoryAccessibilityIdentifier: String? {
		switch historyExposure {
		case let .encounter(risk):
			switch risk {
			case .low:
				return AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelLow
			case .high:
				return AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelHigh
			}
		case .none:
			return nil
		}
	}

	var exposureHistoryImage: UIImage? {
		switch historyExposure {
		case let .encounter(risk):
			switch risk {
			case .low:
				return UIImage(imageLiteralResourceName: "Icons_Attention_low")
			case .high:
				return UIImage(imageLiteralResourceName: "Icons_Attention_high")
			}
		case .none:
			return nil
		}
	}

	var exposureHistoryTitle: String? {
		switch historyExposure {
		case let .encounter(risk):
			switch risk {
			case .low:
				return AppStrings.ContactDiary.Overview.lowRiskTitle
			case .high:
				return AppStrings.ContactDiary.Overview.increasedRiskTitle
			}

		case .none:
			return nil
		}
	}

	var exposureHistoryDetail: String? {
		switch historyExposure {
		case .encounter:
			return selectedEntries.isEmpty ?
				AppStrings.ContactDiary.Overview.riskText1 :
				[AppStrings.ContactDiary.Overview.riskText1, AppStrings.ContactDiary.Overview.riskText2].joined(separator: "\n")

		case .none:
			return nil
		}
	}

	var selectedEntries: [DiaryEntry] {
		diaryDay.selectedEntries
	}

	var formattedDate: String {
		diaryDay.formattedDate
	}

	// MARK: - Private

	private let diaryDay: DiaryDay

	private var dateComponentsFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.zeroFormattingBehavior = .pad
		formatter.allowedUnits = [.hour, .minute]
		return formatter
	}()
}
