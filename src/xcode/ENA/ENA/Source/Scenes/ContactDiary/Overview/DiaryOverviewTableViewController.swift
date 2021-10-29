////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryOverviewTableViewController: UITableViewController {

	// MARK: - Init

	init(
		viewModel: DiaryOverviewViewModel,
		onCellSelection: @escaping (DiaryDay) -> Void,
		onMoreButtonTap: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onCellSelection = onCellSelection
		self.onMoreButtonTap = onMoreButtonTap

		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBindings()
		setupTableView()

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.ContactDiary.Overview.title

		view.backgroundColor = .enaColor(for: .darkBackground)
		
		let moreImage = UIImage(named: "Icons_More_Circle")
		let rightBarButton = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(onMore))
		rightBarButton.accessibilityLabel = AppStrings.ContactDiary.Overview.menuButtonTitle
		rightBarButton.tintColor = .enaColor(for: .tint)
		navigationItem.setRightBarButton(rightBarButton, animated: false)
		navigationItem.setHidesBackButton(true, animated: false)
		navigationController?.navigationBar.sizeToFit()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch DiaryOverviewViewModel.Section(rawValue: indexPath.section) {
		case .description:
			return descriptionCell(forRowAt: indexPath)
		case .days:
			return dayCell(forRowAt: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath.section == 1 else {
			return
		}

		onCellSelection(viewModel.day(by: indexPath))
	}

	// MARK: - Private

	private let viewModel: DiaryOverviewViewModel
	private let onCellSelection: (DiaryDay) -> Void
	private let onMoreButtonTap: () -> Void

	private var subscriptions = [AnyCancellable]()
	
	private func setupBindings() {
		viewModel.$days
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)
		
		viewModel.homeState?.$riskState
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)
	}

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: DiaryOverviewDescriptionTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryOverviewDescriptionTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: DiaryOverviewDayTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryOverviewDayTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
		
		tableView.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.Overview.tableView
	}

	private func descriptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryOverviewDescriptionTableViewCell.self), for: indexPath) as? DiaryOverviewDescriptionTableViewCell else {
			fatalError("Could not dequeue DiaryOverviewDescriptionTableViewCell")
		}

		return cell
	}

	private func dayCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryOverviewDayTableViewCell.self), for: indexPath) as? DiaryOverviewDayTableViewCell else {
			fatalError("Could not dequeue DiaryOverviewDayTableViewCell")
		}
		cell.configure(cellViewModel: viewModel.cellModel(for: indexPath))
		return cell
	}
	
	@objc
	private func onMore() {
		onMoreButtonTap()
	}

}
