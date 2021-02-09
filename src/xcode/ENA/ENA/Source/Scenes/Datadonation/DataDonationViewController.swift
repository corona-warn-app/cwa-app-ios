////
// 🦠 Corona-Warn-App
//

import UIKit

class DataDonationViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol {

	// MARK: - Init
	init(
		didTapSelectCountry: @escaping () -> Void,
		didTapSelectRegion: @escaping () -> Void,
		didTapSelectAge: @escaping () -> Void,
		didTapLegal: @escaping () -> Void
	) {
		self.didTapSelectAge = didTapSelectAge
		self.didTapSelectRegion = didTapSelectRegion
		self.didTapSelectCountry = didTapSelectCountry
		self.didTapLegal = didTapLegal

		self.viewModel = DataDonationViewModel()
		
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		//setupDummyView()
		setupTableView()
	}

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal
	
	var finished: (() -> Void)?

	// MARK: - Private

	private let didTapSelectCountry: () -> Void
	private let didTapSelectRegion: () -> Void
	private let didTapSelectAge: () -> Void
	private let didTapLegal: () -> Void

	private let viewModel: DataDonationViewModel

	private func setupDummyView() {
		title = "DataDonation"
		view.backgroundColor = .enaColor(for: .background)

		let firstButton = UIButton(type: .custom)
		firstButton.translatesAutoresizingMaskIntoConstraints = false
		firstButton.setTitle("Land", for: .normal)
		firstButton.setTitleColor(.black, for: .normal)
		firstButton.backgroundColor = .enaColor(for: .buttonPrimary)
		firstButton.addTarget(self, action: #selector(didTapSelectCountryButton), for: .touchUpInside)

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
	
	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

	@objc
	private func didTapSelectCountryButton() {
		Log.debug("Did hit select country Button")
	}

	@objc
	private func didTapSelectRegionButton() {
		Log.debug("Did hit select region Button")
	}

	@objc
	private func didTapAgeButton() {
		Log.debug("Did hit select age Button")
	}
}

// MARK: - Cell reuse identifiers.

extension DataDonationViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
