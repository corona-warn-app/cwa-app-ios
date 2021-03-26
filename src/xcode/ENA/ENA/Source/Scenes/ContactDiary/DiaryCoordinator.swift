//
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryCoordinator {

	// MARK: - Init

	init(
		store: Store,
		diaryStore: DiaryStoringProviding,
		eventStore: EventStoringProviding,
		homeState: HomeState?
	) {
		self.store = store
		self.diaryStore = diaryStore
		self.eventStore = eventStore
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
			return ENANavigationControllerWithFooter(rootViewController: infoScreen(hidesCloseButton: true, dismissAction: { [weak self] in
				guard let self = self else { return }
				self.viewController.pushViewController(self.overviewScreen, animated: true)	// Push Overview
				self.viewController.setViewControllers([self.overviewScreen], animated: false) // Set Overview as the only Controller on the navigation stack to avoid back gesture etc.
				self.infoScreenShown = true
				// open current day screen if necessary
				if self.showCurrentDayScreenAfterInfoScreen {
					self.showCurrentDayScreenAfterInfoScreen = false
					self.showCurrentDayScreen()
				}
			},
			showDetail: { detailViewController in
				self.viewController.pushViewController(detailViewController, animated: true)
			}))
		} else {
			return ENANavigationControllerWithFooter(rootViewController: overviewScreen)
		}
	}()


	/// Directly open the current day view. Used for deep links & shortcuts
	func showCurrentDayScreen() {
		// prevent navigation issues by falling back to overview screen
		viewController.popToRootViewController(animated: false)
		// dismiss all presented view controllers
		viewController.view.window?.rootViewController?.dismiss(animated: false, completion: { [weak self] in
			guard let self = self else {
				return
			}
			// Info view MUST be shown
			guard self.infoScreenShown else {
				Log.debug("Diary info screen not shown. Skipping further navigation", log: .ui)
				// set this to true to open current day screen after info screen has been dismissed
				self.showCurrentDayScreenAfterInfoScreen = true
				return
			}
			// check if the data model is correct
			let model = DiaryOverviewViewModel(
				diaryStore: self.diaryStore,
				store: self.store,
				eventStore: self.eventStore,
				homeState: self.homeState
			)
			guard let today = model.days.first else {
				Log.warning("Can't get 'today' from `DiaryOverviewViewModel`. Discarding further quick action handling.", log: .ui)
				return
			}
			// now show the screen
			self.showDayScreen(day: today)
		})
	}
	
	// MARK: - Private

	private let store: Store
	private let diaryStore: DiaryStoringProviding
	private let eventStore: EventStoringProviding
	private let homeState: HomeState?

	private var infoScreenShown: Bool {
		get { store.journalWithExposureHistoryInfoScreenShown }
		set { store.journalWithExposureHistoryInfoScreenShown = newValue }
	}
	private var showCurrentDayScreenAfterInfoScreen: Bool = false

	// MARK: Show Screens

	private lazy var overviewScreen: DiaryOverviewTableViewController = {
		return DiaryOverviewTableViewController(
			viewModel: DiaryOverviewViewModel(
				diaryStore: diaryStore,
				store: store,
				eventStore: eventStore,
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
	

	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (() -> Void),
		showDetail: @escaping ((UIViewController) -> Void)
	) -> UIViewController {
		
		let viewController = DiaryInfoViewController(
			viewModel: DiaryInfoViewModel(
				presentDisclaimer: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					showDetail(detailViewController)
				},
				hidesCloseButton: hidesCloseButton
			),
			onDismiss: {
				dismissAction()
			}
		)
			
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.ContactDiary.Information.primaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: viewController,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}
	
	private func presentInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let infoVC = infoScreen(
			dismissAction: {
				navigationController.dismiss(animated: true)
			},
			showDetail: { detailViewController in
				navigationController.pushViewController(detailViewController, animated: true)
			}

		)

		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = UINavigationController(rootViewController: infoVC)
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
			),
			onInfoButtonTap: { [weak self] in
				self?.showDiaryDayNotesInfoScreen()
			}
		)
		
		if let currentDayVC = self.viewController.viewControllers.last as? DiaryDayViewController, currentDayVC.day == day {
			// prevent pushing the same day again
			return
		}

		// reset to root before showing day
		self.viewController.popToRootViewController(animated: false)
		
		self.viewController.pushViewController(viewController, animated: true)
	}

	private func showAddAndEditEntryScreen(mode: DiaryAddAndEditEntryViewModel.Mode, from fromViewController: UIViewController? = nil) {
		let presentingViewController = fromViewController ?? viewController

		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: mode,
			store: diaryStore
		)

		let viewController = DiaryAddAndEditEntryViewController(
			viewModel: viewModel,
			dismiss: {
				presentingViewController.dismiss(animated: true)
			}
		)
		let navigationController = ENANavigationControllerWithFooter(rootViewController: viewController)

		presentingViewController.present(navigationController, animated: true)
	}

	private func showDiaryDayNotesInfoScreen() {
		var navigationController: UINavigationController!

		let viewController = DiaryDayNotesInfoViewController(
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)

		navigationController = UINavigationController(rootViewController: viewController)
		navigationController.navigationBar.prefersLargeTitles = true

		self.viewController.present(navigationController, animated: true)
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
				self?.viewController.dismiss(animated: true)
			}
		)
		navigationController = UINavigationController(rootViewController: viewController)
		self.viewController.present(navigationController, animated: true)
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
		self.viewController.present(viewController, animated: true, completion: nil)
	}
	
}
