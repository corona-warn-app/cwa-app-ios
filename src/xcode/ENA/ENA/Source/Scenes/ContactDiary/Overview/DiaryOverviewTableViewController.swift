////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryOverviewTableViewController: UITableViewController {

	// MARK: - Init

	init(
		diaryService: DiaryService,
		onCellSelection: @escaping (DiaryDay) -> Void,
		onInfoButtonTap: @escaping () -> Void,
		onExportButtonTap: @escaping () -> Void,
		onEditContactPersonsButtonTap: @escaping () -> Void,
		onEditLocationsButtonTap: @escaping () -> Void
	) {
		self.diaryService = diaryService
		self.onCellSelection = onCellSelection
		self.onInfoButtonTap = onInfoButtonTap
		self.onExportButtonTap = onExportButtonTap
		self.onEditContactPersonsButtonTap = onEditContactPersonsButtonTap
		self.onEditLocationsButtonTap = onEditLocationsButtonTap

		super.init(style: .plain)

		diaryService.$days
			.receive(on: RunLoop.main.ocombine)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.ContactDiary.Overview.title

		view.backgroundColor = .enaColor(for: .darkBackground)
		
		let moreImage = UIImage(named: "Icons_More_Circle")
		let rightBarButton = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(onMore))
		rightBarButton.tintColor = .enaColor(for: .tint)
		self.navigationItem.setRightBarButton(rightBarButton, animated: false)
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section) {
		case .description:
			return 1
		case .days:
			return diaryService.days.count
		case .none:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
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

		onCellSelection(diaryService.days[indexPath.row])
	}

	// MARK: - Private

	private enum Section: Int, CaseIterable {
		case description
		case days
	}

	private let diaryService: DiaryService
	private let onCellSelection: (DiaryDay) -> Void
	private let onInfoButtonTap: () -> Void
	private let onExportButtonTap: () -> Void
	private let onEditContactPersonsButtonTap: () -> Void
	private let onEditLocationsButtonTap: () -> Void

	private var subscriptions = [AnyCancellable]()

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

		cell.configure(day: diaryService.days[indexPath.row])

		return cell
	}
	
	@objc
	private func onMore() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let infoAction = UIAlertAction(title: AppStrings.ContactDiary.Overview.ActionSheet.infoActionTitle, style: .default, handler: { [weak self] _ in
			self?.onInfoButtonTap()
		})
		actionSheet.addAction(infoAction)
		
		let exportAction = UIAlertAction(title: AppStrings.ContactDiary.Overview.ActionSheet.exportActionTitle, style: .default, handler: { [weak self] _ in
			self?.onExportButtonTap()
		})
		actionSheet.addAction(exportAction)

		let editPerson = UIAlertAction(title: AppStrings.ContactDiary.Overview.ActionSheet.editPersonTitle, style: .default, handler: { [weak self] _ in
			self?.onEditContactPersonsButtonTap()
		})
		actionSheet.addAction(editPerson)
		
		let editLocation = UIAlertAction(title: AppStrings.ContactDiary.Overview.ActionSheet.editLocationTitle, style: .default, handler: { [weak self] _ in
			self?.onEditLocationsButtonTap()
		})
		actionSheet.addAction(editLocation)
		
		let cancelAction = UIAlertAction(title: AppStrings.Common.alertActionCancel, style: .cancel, handler: nil)
		actionSheet.addAction(cancelAction)
		
		present(actionSheet, animated: true, completion: nil)
	}
}
