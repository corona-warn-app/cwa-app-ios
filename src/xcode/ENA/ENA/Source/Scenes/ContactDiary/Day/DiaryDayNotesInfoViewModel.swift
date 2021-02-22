//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DiaryDayNotesInfoViewModel {
	
	// MARK: - Init

	init() { }

	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						.body(text: "\(AppStrings.ContactDiary.NotesInformation.description)")
					]
				)
			)
		}
	}
}
