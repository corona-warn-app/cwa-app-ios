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

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

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
		guard let imagename = model.exposureEncounter.imageName else {
			return UIImage()
		}
		return UIImage(imageLiteralResourceName: imagename)
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
