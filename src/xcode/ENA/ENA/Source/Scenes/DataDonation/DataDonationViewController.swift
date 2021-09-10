//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DataDonationViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol, DismissHandling {

	// MARK: - Init

	init(
		viewModel: DataDonationViewModelProtocol,
		largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .never
	) {
		self.viewModel = viewModel
		self.largeTitleDisplayMode = largeTitleDisplayMode

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		// if the view controller is direct child of a navigation controller, it can use its own navigation item
		// but if not, e.g. it is embedded in a (custom) container view controller, it must use its parent's item
		let effectiveNavigationItem = (parent is UINavigationController) ? navigationItem : parent?.navigationItem
		effectiveNavigationItem?.title = AppStrings.DataDonation.Info.title
		effectiveNavigationItem?.largeTitleDisplayMode = largeTitleDisplayMode
		navigationController?.navigationBar.prefersLargeTitles = true
		setupTableView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.prefersLargeTitles = true
	}

	// MARK: - Protocol DeltaOnboardingViewControllerProtocol

	var finished: (() -> Void)?

	// MARK: - Private

	private let viewModel: DataDonationViewModelProtocol
	private let largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode
	private var subscriptions: [AnyCancellable] = []

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)
		
		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.legalExtended.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel

		viewModel.dataDonationModelPublisher
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.dynamicTableViewModel = self.viewModel.dynamicTableViewModel
				self.tableView.reloadData()
			}.store(in: &subscriptions)
	}
}

// MARK: - Cell reuse identifiers.

internal extension DataDonationViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
		case legalExtended = "DynamicLegalExtendedCell"
	}
}
