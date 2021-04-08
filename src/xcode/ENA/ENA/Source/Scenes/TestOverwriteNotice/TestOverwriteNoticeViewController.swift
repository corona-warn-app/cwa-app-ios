////
// 🦠 Corona-Warn-App
//

import UIKit

class TestOverwriteNoticeViewController: UITableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		testType: CoronaTestType,
		didTapPrimaryButton: @escaping () -> Void,
		didTapSecondaryButton: @escaping () -> Void
	) {
		self.viewModel = TestOverwriteNoticeViewModel(testType)
		self.didTapPrimaryButton = didTapPrimaryButton
		self.didTapSecondaryButton = didTapSecondaryButton
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			didTapPrimaryButton()
		case .secondary:
			didTapSecondaryButton()
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: TestOverwriteNoticeViewModel
	private let didTapPrimaryButton: () -> Void
	private let didTapSecondaryButton: () -> Void


}
