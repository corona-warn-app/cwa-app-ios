//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class FamilyMemberConsentViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		dismiss: @escaping () -> Void,
		didTapDataPrivacy: @escaping () -> Void,
		didTapSubmit: @escaping (String) -> Void
	) {
		self.dismiss = dismiss
		self.didTapSubmit = didTapSubmit
		self.viewModel = FamilyMemberConsentViewModel(
			presentDisclaimer: didTapDataPrivacy
		)
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupNavigationBar()
		setupTableView()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			guard let familyMemberName = viewModel.name else {
				Log.error("No family member name given - stop here")
				return
			}
			didTapSubmit(familyMemberName)
		case .secondary:
			Log.error("This view doesn't have a secondary button")
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let dismiss: () -> Void
	private let didTapSubmit: (String) -> Void
	private let viewModel: FamilyMemberConsentViewModel

	private var subscriptions = Set<AnyCancellable>()

	private func setupNavigationBar() {
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none

		viewModel.$isPrimaryButtonEnabled
			.sink { [weak self] isEnabled in
				self?.footerView?.setEnabled(isEnabled, button: .primary)
			}
			.store(in: &subscriptions)
	}

}
