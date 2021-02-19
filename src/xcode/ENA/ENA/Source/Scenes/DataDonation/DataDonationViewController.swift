//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DataDonationViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol, ENANavigationControllerWithFooterChild, DismissHandling {
	
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

		setupTableView()
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.save(consentGiven: true)
		finished?()
	}
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		viewModel.save(consentGiven: false)
		finished?()
	}

	// MARK: - Internal

	/// Is called when when the one of the ENANavigationControllerWithFooter buttons is tapped.
	var finished: (() -> Void)?

	// MARK: - Private

	private let viewModel: DataDonationViewModelProtocol
	private var subscriptions: [AnyCancellable] = []

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.DataDonation.Info.buttonOK
		item.isPrimaryButtonEnabled = true

		item.secondaryButtonTitle = AppStrings.DataDonation.Info.buttonNOK
		item.secondaryButtonHasBackground = true
		item.isSecondaryButtonHidden = false
		item.isSecondaryButtonEnabled = true
		
		item.title = AppStrings.DataDonation.Info.title

		return item
	}()

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
