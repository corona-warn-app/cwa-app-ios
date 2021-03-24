////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class EditCheckinDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FooterViewHandling {

	// MARK: - Init

	init(
		checkIn: Checkin,
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.viewModel = EditCheckinDetailViewModel(checkIn)

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
//		setupNavigationBar()
		setupView()
		setupTableView()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		footerView?.setLoadingIndicator(true, disable: true, button: .primary)
		// ToDo remove delay
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
			self?.dismiss()
		}
	}

	// MARK: - UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return EditCheckinDetailViewModel.TableViewSections.allCases.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(EditCheckinDetailViewModel.TableViewSections(rawValue: section))
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = EditCheckinDetailViewModel.TableViewSections(rawValue: indexPath.section) else {
			fatalError("unknown section - can't match a cell type")
		}
		switch section {
		case .description:
			let cell = tableView.dequeueReusableCell(cellType: CheckInDescriptionCell.self, for: indexPath)
			cell.configure(cellModel: viewModel.checkInDescriptionCellModel)
			return cell

		case .checkInStart:
			let cell = tableView.dequeueReusableCell(cellType: CheckInTimeWithPickerCell.self, for: indexPath)
			cell.configure(viewModel.checkInStartCellModel)
			return cell
		}

	}

	// MARK: - UITableViewDelegate

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let sectionTitle = EditCheckinDetailViewModel.TableViewSections(rawValue: section)?.sectionTitle,
			  let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TextHeaderView.reuseIdentifier) as? TextHeaderView else {
			let view = UIView(frame: .zero)
			view.backgroundColor = .enaColor(for: .cellBackground)
			return view
		}
		headerView.configure(sectionTitle)
		return headerView
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView(frame: .zero)
		view.backgroundColor = .enaColor(for: .cellBackground)
		return view
	}

	// MARK: - Private
	
	private let viewModel: EditCheckinDetailViewModel
	private let dismiss: () -> Void

	private var subscriptions = Set<AnyCancellable>()
	private var selectedDuration: Int?
	private var isInitialSetup = true
	private var tableView = UITableView(frame: .zero, style: .grouped)

	private func setupNavigationBar() {
//		let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App").withRenderingMode(.alwaysTemplate)
//		let logoImageView = UIImageView(image: logoImage)
//		logoImageView.tintColor = .enaColor(for: .textContrast)
//		parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)
//		parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss, contrastMode: true)

//		parent?.navigationController?.navigationBar.isTranslucent = true
	}

	private func setupView() {
		parent?.view.backgroundColor = .clear
		let backGroundView = GradientBackgroundView()
		backGroundView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(backGroundView)

		let gradientNavigationView = GradientNavigationView()
		gradientNavigationView.translatesAutoresizingMaskIntoConstraints = false
		backGroundView.addSubview(gradientNavigationView)

		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = .clear
		backGroundView.addSubview(tableView)

		NSLayoutConstraint.activate(
			[
				backGroundView.topAnchor.constraint(equalTo: view.topAnchor),
				backGroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

				gradientNavigationView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 24.0),
				gradientNavigationView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16.0),
				gradientNavigationView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16.0),

				tableView.topAnchor.constraint(equalTo: gradientNavigationView.bottomAnchor, constant: 20.0),
				tableView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor),
				tableView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor),
				tableView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor)
		])

		/*
		checkInForLabel.text = AppStrings.Checkins.Details.checkinFor
		activityLabel.text = AppStrings.Checkins.Details.activity
		saveToDiaryLabel.text = AppStrings.Checkins.Details.saveToDiary
		automaticCheckOutLabel.text = AppStrings.Checkins.Details.automaticCheckout
		logoImageView.image = logoImageView.image?.withRenderingMode(.alwaysTemplate)
		logoImageView.tintColor = .enaColor(for: .textContrast)
		addBorderAndColorToView(descriptionView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(bottomCardView, color: .enaColor(for: .hairline))

		viewModel.$descriptionLabelTitle
			.sink { [weak self] description in
				self?.descriptionLabel.text = description
			}
			.store(in: &subscriptions)
		
		viewModel.$addressLabelTitle
			.sink { [weak self] address in
				self?.addressLabel.text = address
			}
			.store(in: &subscriptions)
		
		viewModel.$initialDuration
			.sink { [weak self] duration in
				self?.selectedDuration = duration
				self?.setupPicker(with: duration ?? 0)

			}
			.store(in: &subscriptions)
*/
	}

	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.separatorStyle = .none

		tableView.estimatedSectionHeaderHeight = 3.5
		tableView.sectionHeaderHeight = UITableView.automaticDimension

		tableView.estimatedSectionFooterHeight = 3.5
		tableView.sectionFooterHeight = UITableView.automaticDimension

		tableView.register(TextHeaderView.self, forHeaderFooterViewReuseIdentifier: TextHeaderView.reuseIdentifier)
		tableView.register(CheckInDescriptionCell.self, forCellReuseIdentifier: CheckInDescriptionCell.reuseIdentifier)
		tableView.register(CheckInTimeWithPickerCell.self, forCellReuseIdentifier: CheckInTimeWithPickerCell.reuseIdentifier)
	}

}
