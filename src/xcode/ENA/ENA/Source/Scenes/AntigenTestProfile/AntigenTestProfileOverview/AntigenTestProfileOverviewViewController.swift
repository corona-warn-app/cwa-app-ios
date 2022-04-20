//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AntigenTestProfileOverviewViewController: UITableViewController, DismissHandling {

	// MARK: - Init

	init(
		viewModel: AntigenTestProfileOverviewViewModel,
		onInfoButtonTap: @escaping () -> Void,
		onAddEntryCellTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onInfoButtonTap = onInfoButtonTap
		self.onAddEntryCellTap = onAddEntryCellTap
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

		view.backgroundColor = .enaColor(for: .darkBackground)

		setupBarButtonItems()
		setupTableView()
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.AntigenProfile.Overview.title

		viewModel.$antigenTestProfiles
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self else { return }
				
				self.tableView.reloadData()
				self.updateEmptyState()
			}
			.store(in: &subscriptions)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		viewModel.refreshFromStore()
		
		parent?.navigationController?.navigationBar.prefersLargeTitles = true
		parent?.navigationController?.navigationBar.sizeToFit()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateEmptyState()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch AntigenTestProfileOverviewViewModel.Section(rawValue: indexPath.section) {
		case .add:
			return antigenTestProfileAddCell(forRowAt: indexPath)
		case .entries:
			return antigenTestPersonProfileCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch AntigenTestProfileOverviewViewModel.Section(rawValue: indexPath.section) {
		case .add:
			onAddEntryCellTap()
		case .entries:
			viewModel.didTapEntryCell(at: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}
	
	// MARK: - Private

	private let viewModel: AntigenTestProfileOverviewViewModel
	private let onInfoButtonTap: () -> Void
	private let onAddEntryCellTap: () -> Void
	private let onDismiss: () -> Void

	private var subscriptions = [AnyCancellable]()

	private var addEntryCellModel = AddAntigenTestProfileCellModel()

	private func setupBarButtonItems() {
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		navigationItem.rightBarButtonItems = [dismissHandlingCloseBarButton, UIBarButtonItem(customView: infoButton)]
		navigationItem.rightBarButtonItems?[0].isAccessibilityElement = true
		navigationItem.rightBarButtonItems?[0].accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItems?[0].accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItems?[1].isAccessibilityElement = true
		navigationItem.rightBarButtonItems?[1].accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItems?[1].accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
	}
	
	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: AddButtonAsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: AddButtonAsTableViewCell.self)
		)

		tableView.register(AntigenTestPersonProfileCell.self, forCellReuseIdentifier: AntigenTestPersonProfileCell.reuseIdentifier)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
		tableView.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Overview.tableView
	}

	private func antigenTestProfileAddCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddButtonAsTableViewCell.self), for: indexPath) as? AddButtonAsTableViewCell else {
			fatalError("Could not dequeue AddButtonAsTableViewCell")
		}

		cell.configure(cellModel: addEntryCellModel)

		return cell
	}

	private func antigenTestPersonProfileCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AntigenTestPersonProfileCell.self), for: indexPath) as? AntigenTestPersonProfileCell else {
			fatalError("Could not dequeue AntigenTestPersonProfileCell")
		}

		let cellModel = viewModel.antigenTestPersonProfileCellModel(at: indexPath)
		
		cell.configure(
			with: cellModel
		)

		return cell
	}

	private func updateEmptyState() {
		// Since we set the empty state view as a background view we need to push it into the visible area by
		// adding the height of the button cell to the safe area (navigation bar and status bar)
		let safeInsetTop = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).maxY + tableView.adjustedContentInset.top
		// If possible, we want to push it to a position that looks good on large and small screens and that is aligned
		// between CheckinsOverviewViewController, TraceLocationsOverviewViewController,  HealthCertificateOverviewViewController and AntigenTestProfileOverviewViewController
		let alignmentPadding = UIScreen.main.bounds.height / 3
		tableView.backgroundView = viewModel.isEmpty
			? EmptyStateView(
				viewModel: AntigenTestProfileOverviewEmptyStateViewModel(),
				safeInsetTop: safeInsetTop,
				alignmentPadding: alignmentPadding
			)
			: nil
	}

	@objc
	private func infoButtonTapped() {
		onInfoButtonTap()
	}
}
