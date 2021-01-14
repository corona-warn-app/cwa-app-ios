////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DiaryOverviewDayCellModel {

	// MARK: - Init

	init(_ model: DiaryDay) {
		self.model = model
	}

	// MARK: - Public

	// MARK: - Internal

	var showExposureHistory: Bool {
		switch model.exposureEncounter {
		case .none:
			return false
		case .encounter:
			return true
		}
	}

	var exposureHistoryImage: UIImage {
		switch model.exposureEncounter {
		case let .encounter(risk):
			switch risk {
			case .low:
				return UIImage(imageLiteralResourceName: "Icons_Attention_low")
			case .high:
				return UIImage(imageLiteralResourceName: "Icons_Attention_high")
			}
		case .none:
			return UIImage()
		}
	}

	var exposureHistoryTitle: String? {
		switch model.exposureEncounter {
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
		switch model.exposureEncounter {
		case .encounter:
			return selectedEntries.isEmpty ?
				AppStrings.ContactDiary.Overview.riskText1 :
				[AppStrings.ContactDiary.Overview.riskText1, AppStrings.ContactDiary.Overview.riskText2].joined(separator: "\n")

		case .none:
			return nil
		}
	}

	var selectedEntries: [DiaryEntry] {
		model.selectedEntries
	}

	var formattedDate: String {
		model.formattedDate
	}

	// MARK: - Private

	private let model: DiaryDay

}
