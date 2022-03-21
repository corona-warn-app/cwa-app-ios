//
// 🦠 Corona-Warn-App
//

import UIKit

class FamilyMemberConsentViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		dismiss: @escaping () -> Void,
		didTapDataPrivacy: @escaping () -> Void,
		didTapSubmit: @escaping (String) -> Void
	) {
		self.dismiss = dismiss
		self.didTapSubmit = didTapSubmit
		self.didTapDataPrivacy = didTapDataPrivacy
		self.viewModel = FamilyMemberConsentViewModel()
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

	// MARK: - Protocol TableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return 0
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let dismiss: () -> Void
	private let didTapSubmit: (String) -> Void
	private let didTapDataPrivacy: () -> Void
	private let viewModel: FamilyMemberConsentViewModel

	private func setupNavigationBar() {
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)

	}

}
