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
		parentNavigationController?.pushViewController(overviewScreen, animated: true)

		if !infoScreenShown {
			showInfoScreen()
		}
	}

	// MARK: - Private

	private let store: Store
	private let diaryService: DiaryService

	private weak var parentNavigationController: UINavigationController?

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
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: ENANavigationControllerWithFooter!
		let viewController = DiaryInfoViewController(
			viewModel: DiaryInfoViewModel(
				presentDisclaimer: {
					let detailViewController = AppInformationDetailViewController()
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.dynamicTableViewModel = AppInformationModel.privacyModel
					detailViewController.separatorStyle = .none
					// hides the footerview as well
					detailViewController.hidesBottomBarWhenPushed = true
					navigationController.pushViewController(detailViewController, animated: true)
				}
			),
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)
		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = ENANavigationControllerWithFooter(rootViewController: viewController)
		parentNavigationController?.present(navigationController, animated: true) {
			self.infoScreenShown = true
		}
	}

	private func showDayScreen(day: DiaryDay) {
		let viewController = DiaryDayViewController(
			viewModel: DiaryDayViewModel(day: day, store: diaryService.store),
			onAddEntryCellTap: { [weak self] day, entryType in
				self?.showAddAndEditEntryScreen(mode: .add(day, entryType))
			}
		)

		parentNavigationController?.pushViewController(viewController, animated: true)
	}

	private func showAddAndEditEntryScreen(mode: DiaryAddAndEditEntryViewModel.Mode) {
		let navigationController = UINavigationController()

		let viewController = DiaryAddAndEditEntryViewController(
			mode: mode,
			diaryService: diaryService,
			onDismiss: { [weak self] in
				self?.parentNavigationController?.dismiss(animated: true)
			}
		)
		navigationController.viewControllers = [viewController]

		parentNavigationController?.present(navigationController, animated: true)
	}

	private func showEditEntriesScreen(type: DiaryEntryType) {
		let navigationController = UINavigationController()

		let viewController = DiaryEditEntriesTableViewController(
			diaryService: diaryService,
			onCellSelection: { [weak self] entry in
				self?.showAddAndEditEntryScreen(mode: .edit(entry))
			},
			onDismiss: { [weak self] in
				self?.parentNavigationController?.dismiss(animated: true)
			}
		)
		navigationController.viewControllers = [viewController]

		parentNavigationController?.present(navigationController, animated: true)
	}

	private func showExportActivity() {
		let viewController = UIActivityViewController(
			activityItems: [diaryService.exportString],
			applicationActivities: nil
		)
		parentNavigationController?.present(viewController, animated: true, completion: nil)
	}
	
}
