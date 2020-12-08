////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryAddAndEditEntryViewController: UIViewController {

	// MARK: - Init

	init(
		mode: DiaryAddAndEditEntryViewModel.Mode,
		diaryService: DiaryService,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = DiaryAddAndEditEntryViewModel(mode: mode, diaryService: diaryService)
		self.onDismiss = onDismiss

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

	private let viewModel: DiaryAddAndEditEntryViewModel
	private let onDismiss: () -> Void

}
