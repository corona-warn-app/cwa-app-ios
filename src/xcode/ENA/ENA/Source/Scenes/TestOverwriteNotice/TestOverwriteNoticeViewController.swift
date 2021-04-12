////
// 🦠 Corona-Warn-App
//

import UIKit

class TestOverwriteNoticeViewController: UITableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		testType: CoronaTestType,
		didTapPrimaryButton: @escaping () -> Void,
		didTapCloseButton: @escaping () -> Void
	) {
		self.viewModel = TestOverwriteNoticeViewModel(testType)
		self.didTapPrimaryButton = didTapPrimaryButton
		self.didTapCloseButton = didTapCloseButton
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		parent?.navigationItem.title = viewModel.title
		parent?.navigationController?.navigationBar.prefersLargeTitles = true
	}

	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		didTapCloseButton()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			didTapPrimaryButton()
		case .secondary:
			didTapCloseButton()
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: TestOverwriteNoticeViewModel
	private let didTapPrimaryButton: () -> Void
	private let didTapCloseButton: () -> Void


}
