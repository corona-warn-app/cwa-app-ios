////
// 🦠 Corona-Warn-App
//

import UIKit

class AntigenTestProfileViewController: UIViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring,
		didTapContinue: @escaping (@escaping (Bool) -> Void) -> Void,
		didTapDeleteProfile: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = AntigenTestProfileViewModel(store: store)
		self.didTapContinue = didTapContinue
		self.didTapDeleteProfile = didTapDeleteProfile
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

		let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App").withRenderingMode(.alwaysTemplate)
		let logoImageView = UIImageView(image: logoImage)
		logoImageView.tintColor = .enaColor(for: .textContrast)

		parent?.navigationController?.navigationBar.tintColor = .white
		parent?.navigationItem.titleView = logoImageView
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton

		navigationController?.viewControllers = [navigationController?.viewControllers.first, navigationController?.viewControllers.last].compactMap { $0 }
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {

		case .primary:
			didTapContinue({ _ in Log.debug("is loading closure here") })
		case .secondary:
			viewModel.deleteProfile()
			didTapDeleteProfile()
		}
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private
	
	private let viewModel: AntigenTestProfileViewModel
	private let didTapContinue: (@escaping (Bool) -> Void) -> Void
	private let didTapDeleteProfile: () -> Void
	private let dismiss: () -> Void

	@objc
	private func backToRootViewController() {
		didTapDeleteProfile()
	}

}
