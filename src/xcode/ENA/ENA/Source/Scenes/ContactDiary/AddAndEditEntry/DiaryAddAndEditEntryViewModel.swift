//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DiaryAddAndEditEntryViewModel {

	enum Mode {
		case add(DiaryDay, DiaryEntryType)
		case edit(DiaryEntry)
	}

	// MARK: - Private

	let mode: Mode?
	let diaryService: DiaryService

}
