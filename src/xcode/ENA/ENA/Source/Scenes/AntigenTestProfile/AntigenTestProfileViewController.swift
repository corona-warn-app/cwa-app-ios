////
// 🦠 Corona-Warn-App
//

import UIKit

class AntigenTestProfileViewController: UIViewController, FooterViewHandling {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring,
		didTapContinue: @escaping () -> Void,
		didTapDeleteProfile: @escaping () -> Void
	) {
		self.viewModel = AntigenTestProfileViewModel(store: store)
		self.didTapContinue = didTapContinue
		self.didTapDeleteProfile = didTapDeleteProfile

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
		switch type {

		case .primary:
			didTapContinue()
		case .secondary:
			viewModel.deleteProfile()
			didTapDeleteProfile()
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private
	
	private let viewModel: AntigenTestProfileViewModel
	private let didTapContinue: () -> Void
	private let didTapDeleteProfile: () -> Void

}
