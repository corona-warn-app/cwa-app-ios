//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DiaryOverviewViewModel {

	// MARK: - Internal

	var numberOfDays: Int {
		diaryService.days.count
	}

	// MARK: - Private

	private let diaryService: DiaryService

}
