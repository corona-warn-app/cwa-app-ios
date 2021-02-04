//
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryCoordinator {

	// MARK: - Init

	init(
		store: Store,
		diaryStore: DiaryStoringProviding,
		homeState: HomeState?
	) {
		self.store = store
		self.diaryStore = diaryStore
		self.homeState = homeState
		
		#if DEBUG
		if isUITesting {
			if let journalWithExposureHistoryInfoScreenShown = UserDefaults.standard.string(forKey: "diaryInfoScreenShown") {
				store.journalWithExposureHistoryInfoScreenShown = (journalWithExposureHistoryInfoScreenShown != "NO")
			}

			if let journalRemoveAllPersons = UserDefaults.standard.string(forKey: "journalRemoveAllPersons"),
			   journalRemoveAllPersons == "YES" {
				diaryStore.removeAllContactPersons()
			}

			if let journalRemoveAllLocations = UserDefaults.standard.string(forKey: "journalRemoveAllLocations"),
			   journalRemoveAllLocations == "YES" {
				diaryStore.removeAllLocations()
			}

		}
		#endif
				
		
	}

	// MARK: - Internal

	lazy var viewController: ENANavigationControllerWithFooter = {
		if !infoScreenShown {
			return ENANavigationControllerWithFooter(rootViewController: infoScreen(modalPresentation: false, dismissAction: { [weak self] in
				guard let self = self else { return }
				self.viewController.pushViewController(self.overviewScreen, animated: true)	// Push Overview
				self.viewController.setViewControllers([self.overviewScreen], animated: false) // Set Overview as the only Controller on the navigation stack to avoid back gesture etc.
			}))
		} else {
			return ENANavigationControllerWithFooter(rootViewController: overviewScreen)
		}
	}()
	
	// MARK: - Private

	private let store: Store
	private let diaryStore: DiaryStoringProviding
	private let homeState: HomeState?

	private weak var parentNavigationController: UINavigationController?

	private var infoScreenShown: Bool {
		get { store.journalWithExposureHistoryInfoScreenShown }
		set { store.journalWithExposureHistoryInfoScreenShown = newValue }
	}

	// MARK: Show Screens

	private lazy var overviewScreen: DiaryOverviewTableViewController = {
		return DiaryOverviewTableViewController(
			viewModel: DiaryOverviewViewModel(
				diaryStore: diaryStore,
				store: store,
				homeState: homeState
			),
			onCellSelection: { [weak self] day in
				self?.showDayScreen(day: day)
			},
			onInfoButtonTap: { [weak self] in
				self?.presentInfoScreen()
			},
			onExportButtonTap: { [weak self] in
				self?.showExportActivity()
			},
			onEditContactPersonsButtonTap: { [weak self] in
				self?.showEditEntriesScreen(entryType: .contactPerson)
			},
			onEditLocationsButtonTap: { [weak self] in
				self?.showEditEntriesScreen(entryType: .location)
			}
		)
	}()
	

	private func infoScreen(modalPresentation: Bool, dismissAction: @escaping (() -> Void)) -> UIViewController {
		let viewController = DiaryInfoViewController(
			viewModel: DiaryInfoViewModel(
				presentDisclaimer: { [weak self] in
					let detailViewController = AppInformationDetailViewController()
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.dynamicTableViewModel = AppInformationModel.privacyModel
					detailViewController.separatorStyle = .none
					// hides the footerview as well
					detailViewController.hidesBottomBarWhenPushed = true
					self?.viewController.pushViewController(detailViewController, animated: true)
				}
			),
			onDismiss: {
				dismissAction()
			}
		)
		return viewController
	}
	
	private func presentInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: ENANavigationControllerWithFooter!
		let infoVC = infoScreen(
			modalPresentation: true,
			dismissAction: {
				navigationController.dismiss(animated: true)
			}
		)
							
		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = ENANavigationControllerWithFooter(rootViewController: infoVC)
		viewController.present(navigationController, animated: true)
	}
	
	private func showDayScreen(day: DiaryDay) {
		let viewController = DiaryDayViewController(
			viewModel: DiaryDayViewModel(
				day: day,
				store: diaryStore,
				onAddEntryCellTap: { [weak self] day, entryType in
					self?.showAddAndEditEntryScreen(mode: .add(day, entryType))
				}
			)
		)

		parentNavigationController?.pushViewController(viewController, animated: true)
	}

	private func showAddAndEditEntryScreen(mode: DiaryAddAndEditEntryViewModel.Mode, from fromViewController: UIViewController? = nil) {
		let presentingViewController = fromViewController ?? parentNavigationController

		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: mode,
			store: diaryStore
		)

		let viewController = DiaryAddAndEditEntryViewController(
			viewModel: viewModel,
			dismiss: {
				presentingViewController?.dismiss(animated: true)
			}
		)
		let navigationController = ENANavigationControllerWithFooter(rootViewController: viewController)

		presentingViewController?.present(navigationController, animated: true)
	}

	private func showEditEntriesScreen(entryType: DiaryEntryType) {
		var navigationController: UINavigationController!

		let viewController = DiaryEditEntriesViewController(
			entryType: entryType,
			store: diaryStore,
			onCellSelection: { [weak self] entry in
				self?.showAddAndEditEntryScreen(
					mode: .edit(entry),
					from: navigationController
				)
			},
			onDismiss: { [weak self] in
				self?.parentNavigationController?.dismiss(animated: true)
			}
		)
		navigationController = UINavigationController(rootViewController: viewController)
		parentNavigationController?.present(navigationController, animated: true)
	}

	private func showExportActivity() {
		let exportString: String
		if case let .success(string) = diaryStore.export() {
			exportString = string
		} else {
			exportString = ""
		}
		let exportItem = DiaryExportItem(subject: AppStrings.ContactDiary.Overview.ActionSheet.exportActionSubject, body: exportString)
		let viewController = UIActivityViewController(
			activityItems: [exportItem],
			applicationActivities: nil
		)
		parentNavigationController?.present(viewController, animated: true, completion: nil)
	}
	
}
