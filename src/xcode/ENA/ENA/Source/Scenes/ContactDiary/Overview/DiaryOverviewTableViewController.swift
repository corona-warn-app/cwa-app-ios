////
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

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
		
		let moreImage = UIImage(named: "Icons_More_Circle")
		let rightBarButton = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(onMore))
		rightBarButton.tintColor = .enaColor(for: .tint)
		self.navigationItem.setRightBarButton(rightBarButton, animated: false)
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return diaryService.days.count
		default:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			return descriptionCell(at: indexPath)
		case 1:
			return dayCell(at: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onCellSelection(diaryService.days[indexPath.row])
	}

	// MARK: - Private

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

	private func descriptionCell(at indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryOverviewDescriptionTableViewCell.self), for: indexPath) as? DiaryOverviewDescriptionTableViewCell else {
			fatalError("Could not dequeue DiaryOverviewDescriptionTableViewCell")
		}

		return cell
	}

	private func dayCell(at indexPath: IndexPath) -> UITableViewCell {
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
