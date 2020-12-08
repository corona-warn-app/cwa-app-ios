////
// 🦠 Corona-Warn-App
//

import UIKit

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
		self.viewModel = DiaryOverviewViewModel(diaryService: diaryService)
		self.onCellSelection = onCellSelection
		self.onInfoButtonTap = onInfoButtonTap
		self.onExportButtonTap = onExportButtonTap
		self.onEditContactPersonsButtonTap = onEditContactPersonsButtonTap
		self.onEditLocationsButtonTap = onEditLocationsButtonTap

		super.init(style: .grouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always

		navigationItem.title = "Kontakt-Tagebuch"
		
		let moreImage = UIImage(named: "Icons_More_Circle")
		let rightBarButton = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(onMore))
		rightBarButton.tintColor = .enaColor(for: .tint)
		self.navigationItem.setRightBarButton(rightBarButton, animated: false)

	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfDays
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryOverviewTableViewCell.self), for: indexPath) as? DiaryOverviewTableViewCell else {
			fatalError("Could not dequeue cell")
		}

		cell.configure(day: viewModel.diaryService.days[indexPath.row])

		return cell
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onCellSelection(viewModel.diaryService.days[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		"Tragen Sie ein, mit wem Sie sich getroffen haben und wo Sie gewesen sind. "
	}

	// MARK: - Private

	private let viewModel: DiaryOverviewViewModel
	private let onCellSelection: (DiaryDay) -> Void
	private let onInfoButtonTap: () -> Void
	private let onExportButtonTap: () -> Void
	private let onEditContactPersonsButtonTap: () -> Void
	private let onEditLocationsButtonTap: () -> Void

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: DiaryOverviewTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryOverviewTableViewCell.self)
		)

		tableView.separatorStyle = .none
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
