////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DiaryOverviewDayCellModel {

	// MARK: - Init

	init(_ diaryDay: DiaryDay) {
		self.diaryDay = diaryDay
	}

	// MARK: - Public

	// MARK: - Internal

	var hideExposureHistory: Bool {
		switch diaryDay.historyExposure {
		case .none:
			return true
		case .encounter:
			return false
		}
	}

	var exposureHistoryImage: UIImage? {
		switch diaryDay.historyExposure {
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
		switch diaryDay.historyExposure {
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
		switch diaryDay.historyExposure {
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

}
