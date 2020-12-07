////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryAddAndEditEntryViewController: UIViewController {

	// MARK: - Init

	init(
		diaryEntry: DiaryEntry?,
		diaryService: DiaryService,
		onPrimaryButtonTap: @escaping () -> Void
	) {
		self.viewModel = DiaryAddAndEditEntryViewModel(diaryEntry: diaryEntry, diaryService: diaryService)
		self.onPrimaryButtonTap = onPrimaryButtonTap

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - Private

	let viewModel: DiaryAddAndEditEntryViewModel
	let onPrimaryButtonTap: () -> Void

}
