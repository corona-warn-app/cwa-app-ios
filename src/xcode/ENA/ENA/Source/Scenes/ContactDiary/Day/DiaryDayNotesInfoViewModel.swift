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
						.title1(text: "\(AppStrings.ContactDiary.NotesInformation.title)", accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.NotesInformation.titel),
						.body(text: "\(AppStrings.ContactDiary.NotesInformation.description)")
					]
				)
			)
		}
	}
}
