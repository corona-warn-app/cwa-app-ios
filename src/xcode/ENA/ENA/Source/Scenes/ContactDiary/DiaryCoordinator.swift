//
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryCoordinator {

	// MARK: - Init

	init(
		store: Store,
		diaryStore: DiaryStoring,
		parentNavigationController: UINavigationController
	) {
		self.store = store
		self.diaryService = DiaryService(store: diaryStore)
		self.parentNavigationController = parentNavigationController
	}

	// MARK: - Internal

	func start() {
		let diaryNavigationController = UINavigationController(rootViewController: overviewScreen)
		parentNavigationController?.pushViewController(diaryNavigationController, animated: true)

		navigationController = diaryNavigationController

		if !infoScreenShown {
			showInfoScreen()
		}
	}

	// MARK: - Private

	private let store: Store
	private let diaryService: DiaryService

	private weak var parentNavigationController: UINavigationController?
	private var navigationController: UINavigationController?

	private var infoScreenShown: Bool {
		get { store.diaryInfoScreenShown }
		set { store.diaryInfoScreenShown = newValue }
	}

	// MARK: Show Screens

	lazy var overviewScreen: DiaryOverviewTableViewController = {
		return DiaryOverviewTableViewController(
			diaryService: diaryService,
			onCellSelection: { [weak self] day in
				self?.showDayScreen(day: day)
			},
			onInfoButtonTap: { [weak self] in
				self?.showInfoScreen()
			},
			onExportButtonTap: { [weak self] in
				self?.showExportActivity()
			},
			onEditContactPersonsButtonTap: { [weak self] in
				self?.showEditEntriesScreen(type: .contactPerson)
			},
			onEditLocationsButtonTap: { [weak self] in
				self?.showEditEntriesScreen(type: .location)
			}
		)
	}()

	private func showInfoScreen() {
		let vc = DiaryInfoViewController(
			onPrimaryButtonTap: { [weak self] in
				self?.navigationController?.dismiss(animated: true)
			}
		)

		navigationController?.present(vc, animated: true) {
			self.infoScreenShown = true
		}
	}

	private func showDayScreen(day: DiaryDay) {
		let vc = DiaryDayTableViewController(
			diaryDayService: DiaryDayService(day: day, store: diaryService.store),
			onAddEntryCellTap: { [weak self] day, entryType in
				self?.showAddAndEditEntryScreen(mode: .add(day, entryType))
			}
		)

		navigationController?.pushViewController(vc, animated: true)
	}

	private func showAddAndEditEntryScreen(mode: DiaryAddAndEditEntryViewModel.Mode) {
		let vc = DiaryAddAndEditEntryViewController(
			mode: mode,
			diaryService: diaryService,
			onDismiss: { [weak self] in
				self?.navigationController?.dismiss(animated: true)
			}
		)

		navigationController?.present(vc, animated: true)
	}

	private func showEditEntriesScreen(type: DiaryEntryType) {
		let vc = DiaryEditEntriesTableViewController(
			diaryService: diaryService,
			onCellSelection: { [weak self] entry in
				self?.showAddAndEditEntryScreen(mode: .edit(entry))
			},
			onDismiss: { [weak self] in
				self?.navigationController?.dismiss(animated: true)
			}
		)

		navigationController?.present(vc, animated: true)
	}

	private func showExportActivity() {
		let activityViewController = UIActivityViewController(
			activityItems: [diaryService.exportString],
			applicationActivities: nil
		)
		navigationController?.present(activityViewController, animated: true, completion: nil)
	}
	
}
