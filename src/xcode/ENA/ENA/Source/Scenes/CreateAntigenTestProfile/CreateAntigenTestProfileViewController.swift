////
// 🦠 Corona-Warn-App
//

import UIKit

class CreateAntigenTestProfileViewController: UIViewController, FooterViewHandling {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring,
		didTapSave: @escaping () -> Void
	) {
		self.viewModel = CreateAntigenTestProfileViewModel(store: store)
		self.didTapSave = didTapSave

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

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard case .primary = type else {
			return
		}
		viewModel.save()
		didTapSave()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: CreateAntigenTestProfileViewModel
	private let didTapSave: () -> Void

}
