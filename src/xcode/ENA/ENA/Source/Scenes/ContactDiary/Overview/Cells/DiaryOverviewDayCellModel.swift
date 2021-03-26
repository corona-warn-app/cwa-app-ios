////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DiaryOverviewDayCellModel {

	// MARK: - Init

	init(
		_ diaryDay: DiaryDay,
		historyExposure: HistoryExposure,
		minimumDistinctEncountersWithHighRisk: Int
	) {
		self.diaryDay = diaryDay
		self.historyExposure = historyExposure
		self.minimumDistinctEncountersWithHighRisk = minimumDistinctEncountersWithHighRisk
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
		return timeString + " \(AppStrings.ContactDiary.Overview.LocationVisit.abbreviationHours)"
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
		case let .encounter(risk):
			switch risk {
			case .low:
				return selectedEntries.isEmpty ? AppStrings.ContactDiary.Overview.riskTextStandardCause : [AppStrings.ContactDiary.Overview.riskTextStandardCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n")
			case .high where minimumDistinctEncountersWithHighRisk > 0:
				return selectedEntries.isEmpty ? AppStrings.ContactDiary.Overview.riskTextStandardCause : [AppStrings.ContactDiary.Overview.riskTextStandardCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n")
			// for other possible values of minimumDistinctEncountersWithHighRisk such as 0 and -1
			case .high:
				return selectedEntries.isEmpty ? AppStrings.ContactDiary.Overview.riskTextLowRiskEncountersCause : [AppStrings.ContactDiary.Overview.riskTextLowRiskEncountersCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n")
			}
		case .none:
			return nil
		}
	}
	
	var hideCheckinRisk: Bool {
		return false
	}
	
	var checkinTitleText: String {
		return "Erhöhtes Risiko"
	}
	
	var checkinDetailText: String {
		return "aufgrund Ihrer Anwesenheit bei:"
	}
	
	var checkinDetail

	var selectedEntries: [DiaryEntry] {
		diaryDay.selectedEntries
	}

	var formattedDate: String {
		diaryDay.formattedDate
	}

	// MARK: - Private

	private let diaryDay: DiaryDay
	private let minimumDistinctEncountersWithHighRisk: Int

	private var dateComponentsFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.zeroFormattingBehavior = .pad
		formatter.allowedUnits = [.hour, .minute]
		return formatter
	}()

}

private extension ContactPersonEncounter.Duration {
	var description: String {
		switch self {
		case .none:
			return ""
		case .lessThan15Minutes:
			return AppStrings.ContactDiary.Overview.PersonEncounter.durationLessThan15Minutes
		case .moreThan15Minutes:
			return AppStrings.ContactDiary.Overview.PersonEncounter.durationMoreThan15Minutes
		}
	}
}

private extension ContactPersonEncounter.MaskSituation {
	var description: String {
		switch self {
		case .none:
			return ""
		case .withMask:
			return AppStrings.ContactDiary.Overview.PersonEncounter.maskSituationWithMask
		case .withoutMask:
			return AppStrings.ContactDiary.Overview.PersonEncounter.maskSituationWithoutMask
		}
	}
}

private extension ContactPersonEncounter.Setting {
	var description: String {
		   switch self {
		   case .none:
			   return ""
		   case .outside:
			   return AppStrings.ContactDiary.Overview.PersonEncounter.settingOutside
		   case .inside:
			return AppStrings.ContactDiary.Overview.PersonEncounter.settingInside
		   }
	   }
}
