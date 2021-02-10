////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DataDonationViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol, ENANavigationControllerWithFooterChild, DismissHandling {
	
	// MARK: - Init
	init(
		presentSelectValueList: @escaping (SelectValueViewModel) -> Void,
		didTapLegal: @escaping () -> Void
	) {

		self.presentSelectValueList = presentSelectValueList
		self.didTapLegal = didTapLegal
		self.viewModel = DataDonationViewModel(presentSelectValueList: presentSelectValueList)

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

//		setupDummyView()
		setupTableView()
	}
	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}
	
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
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.setConsent(consentGiven: true)
		finished?()
	}
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		viewModel.setConsent(consentGiven: false)
		finished?()
	}

	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		finished?()
	}

	// MARK: - Public

	// MARK: - Internal
	
	var finished: (() -> Void)?

	// MARK: - Private
	private let presentSelectValueList: (SelectValueViewModel) -> Void
	private let didTapLegal: () -> Void

	private let viewModel: DataDonationViewModel
	private var subscriptions: [AnyCancellable] = []

	/*
	private func setupDummyView() {
		title = "DataDonation"
		view.backgroundColor = .enaColor(for: .background)

		let firstButton = UIButton(type: .custom)
		firstButton.translatesAutoresizingMaskIntoConstraints = false
		firstButton.setTitle("Land", for: .normal)
		firstButton.setTitleColor(.black, for: .normal)
		firstButton.backgroundColor = .enaColor(for: .buttonPrimary)
		firstButton.addTarget(self, action: #selector(didTapSelectStateButton), for: .touchUpInside)

		let secondButton = UIButton(type: .custom)
		secondButton.translatesAutoresizingMaskIntoConstraints = false
		secondButton.setTitle("Kreis", for: .normal)
		secondButton.setTitleColor(.black, for: .normal)
		secondButton.backgroundColor = .enaColor(for: .buttonPrimary)
		secondButton.addTarget(self, action: #selector(didTapSelectRegionButton), for: .touchUpInside)

		let thirdButton = UIButton(type: .custom)
		thirdButton.translatesAutoresizingMaskIntoConstraints = false
		thirdButton.setTitle("Alter", for: .normal)
		thirdButton.setTitleColor(.black, for: .normal)
		thirdButton.backgroundColor = .enaColor(for: .buttonPrimary)
		thirdButton.addTarget(self, action: #selector(didTapAgeButton), for: .touchUpInside)

		let stackView = UIStackView(arrangedSubviews: [firstButton, secondButton, thirdButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.spacing = 8.0
		stackView.axis = .vertical
		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -25.0),
			view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 25.0),
			view.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
			firstButton.heightAnchor.constraint(equalToConstant: 40.0)
		])
	}
*/
	
	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)
		
		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.acknowledgement.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel

		viewModel.$reloadTableView
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.dynamicTableViewModel = self.viewModel.dynamicTableViewModel
				self.tableView.reloadData()
			}.store(in: &subscriptions)
	}

	/*
	@objc
	private func didTapSelectStateButton() {
		let selectValueViewModel = SelectValueViewModel(
			viewModel.allFederalStateNames,
			title: AppStrings.DataDonation.ValueSelection.Title.State,
			preselected: viewModel.federalStateName
		)
		selectValueViewModel.$selectedValue.sink { [weak self] federalState in
			guard self?.viewModel.federalStateName != federalState else {
				return
			}
			// if a new fedaral state got selected reset region as well
			self?.viewModel.federalStateName = federalState
			self?.viewModel.region = nil
		}.store(in: &subscriptions)
		presentSelectValueList(selectValueViewModel)
	}

	@objc
	private func didTapSelectRegionButton() {
		guard let federalStateName = viewModel.federalStateName else {
			Log.debug("Missing federal state to load regions", log: .ppac)
			return
		}

		let selectValueViewModel = SelectValueViewModel(
			viewModel.allRegions(by: federalStateName),
			title: AppStrings.DataDonation.ValueSelection.Title.Region,
			preselected: viewModel.region
		)
		selectValueViewModel.$selectedValue .sink { [weak self] region in
			guard self?.viewModel.region != region else {
				return
			}
			self?.viewModel.region = region
		}.store(in: &subscriptions)

		presentSelectValueList(selectValueViewModel)
	}

	@objc
	private func didTapAgeButton() {
		let selectValueViewModel = SelectValueViewModel(
			AgeGroup.allCases.map({ $0.text }),
			title: AppStrings.DataDonation.ValueSelection.Title.Age,
			preselected: viewModel.age
		)
		selectValueViewModel.$selectedValue .sink { [weak self] age in
			guard self?.viewModel.age != age else {
				return
			}
			self?.viewModel.age = age
		}.store(in: &subscriptions)

		presentSelectValueList(selectValueViewModel)
	}
	*/
}

// MARK: - Cell reuse identifiers.

extension DataDonationViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
		case acknowledgement = "DynamicLegalCell"
	}
}
