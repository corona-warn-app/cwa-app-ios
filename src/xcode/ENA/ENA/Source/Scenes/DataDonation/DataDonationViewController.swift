//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DataDonationViewController: DynamicTableViewController, DismissHandling {
	
	// MARK: - Init
	init(
		viewModel: DataDonationViewModelProtocol
	) {
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		if let footerNavigationController = navigationController as? ENANavigationControllerWithFooter {
			footerNavigationController.setFooterViewHidden(false, animated: false)
		}
		title = AppStrings.DataDonation.Info.title
		navigationController?.navigationBar.prefersLargeTitles = true
		setupTableView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let footerNavigationController = navigationController as? ENANavigationControllerWithFooter {
			footerNavigationController.setFooterViewHidden(false, animated: false)
		}

	}

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: DataDonationViewModelProtocol
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
				DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.35) {
					self.tableView.reloadData()
				}
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
