////
// 🦠 Corona-Warn-App
//

import UIKit

class CreateAntigenTestProfileViewController: UIViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring,
		didTapSave: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = CreateAntigenTestProfileViewModel(store: store)
		self.didTapSave = didTapSave
		self.dismiss = dismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		parent?.navigationItem.title = viewModel.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard case .primary = type else {
			return
		}
		viewModel.save()
		didTapSave()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: CreateAntigenTestProfileViewModel
	private let didTapSave: () -> Void
	private let dismiss: () -> Void

}
