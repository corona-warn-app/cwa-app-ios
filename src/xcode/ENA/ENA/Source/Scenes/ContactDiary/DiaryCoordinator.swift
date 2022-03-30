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
		homeState: HomeState
	) {
		self.store = store
		self.diaryStore = diaryStore
		self.eventStore = eventStore
		self.homeState = homeState
		
		#if DEBUG
		if isUITesting {
			store.journalWithExposureHistoryInfoScreenShown = LaunchArguments.infoScreen.diaryInfoScreenShown.boolValue

			if LaunchArguments.contactJournal.journalRemoveAllPersons.boolValue {
				diaryStore.removeAllContactPersons()
			}

			if LaunchArguments.contactJournal.journalRemoveAllLocations.boolValue {
				diaryStore.removeAllLocations()
			}

			if LaunchArguments.contactJournal.journalRemoveAllCoronaTests.boolValue {
				diaryStore.removeAllCoronaTests()
			}

			if let testsLevel = LaunchArguments.contactJournal.testsRiskLevel.stringValue {

				let today = Date()
				let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? Date()

				let todayDateString = DateFormatter.packagesDayDateFormatter.string(from: today)
				let yesterdayDateString = DateFormatter.packagesDayDateFormatter.string(from: yesterday)
				var testResult: TestResult
				switch testsLevel {
				case "high":
					testResult = TestResult.positive
				default:
					testResult = TestResult.negative
				}

				diaryStore.addCoronaTest(
					testDate: todayDateString,
					testType: CoronaTestType.antigen.rawValue,
					testResult: testResult.rawValue
				)
				diaryStore.addCoronaTest(
					testDate: yesterdayDateString,
					testType: CoronaTestType.antigen.rawValue,
					testResult: testResult.rawValue
				)
				diaryStore.addCoronaTest(
					testDate: yesterdayDateString,
					testType: CoronaTestType.pcr.rawValue,
					testResult: testResult.rawValue
				)
			}
		}
		#endif
	}

	// MARK: - Internal

	lazy var viewController: UINavigationController = {
		if !infoScreenShown {
			return NavigationControllerWithLargeTitle(rootViewController: infoScreen(hidesCloseButton: true, dismissAction: { [weak self] in
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
			return NavigationControllerWithLargeTitle(rootViewController: overviewScreen)
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
	private let homeState: HomeState

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
			onMoreButtonTap: { [weak self] in
				self?.showMoreActionSheet()
			}
		)
	}()
	

	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (() -> Void),
		showDetail: @escaping ((UIViewController) -> Void)
	) -> TopBottomContainerViewController<DiaryInfoViewController, FooterViewController> {
		
		let viewController = DiaryInfoViewController(
			viewModel: DiaryInfoViewModel(
				presentDisclaimer: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.isDismissable = false
					if #available(iOS 13.0, *) {
						detailViewController.isModalInPresentation = true
					}
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

		// We need to use NavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = NavigationControllerWithLargeTitle(rootViewController: infoVC)
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

	private func showMoreActionSheet() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let infoAction = UIAlertAction(title: AppStrings.ContactDiary.Overview.ActionSheet.infoActionTitle, style: .default) { [weak self] _ in
			self?.presentInfoScreen()
		}
		actionSheet.addAction(infoAction)

		let exportAction = UIAlertAction(title: AppStrings.ContactDiary.Overview.ActionSheet.exportActionTitle, style: .default) { [weak self] _ in
			self?.showExportActivity()
		}
		actionSheet.addAction(exportAction)

		let editPerson = UIAlertAction(title: AppStrings.ContactDiary.Overview.ActionSheet.editPersonTitle, style: .default) { [weak self] _ in
			self?.showEditEntriesScreen(entryType: .contactPerson)
		}
		editPerson.isEnabled = diaryStore.diaryDaysPublisher.value.first?.entries.contains { $0.type == .contactPerson } ?? false
		actionSheet.addAction(editPerson)

		let editLocation = UIAlertAction(title: AppStrings.ContactDiary.Overview.ActionSheet.editLocationTitle, style: .default) { [weak self] _ in
			self?.showEditEntriesScreen(entryType: .location)
		}
		editLocation.isEnabled = diaryStore.diaryDaysPublisher.value.first?.entries.contains { $0.type == .location } ?? false
		actionSheet.addAction(editLocation)

		let cancelAction = UIAlertAction(title: AppStrings.Common.alertActionCancel, style: .cancel)
		actionSheet.addAction(cancelAction)

		viewController.present(actionSheet, animated: true, completion: nil)
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

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.ContactDiary.AddEditEntry.primaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: viewController,
			bottomController: footerViewController
		)

		let navigationController = NavigationControllerWithLargeTitle(rootViewController: topBottomContainerViewController)
		presentingViewController.present(navigationController, animated: true)
	}

	private func showDiaryDayNotesInfoScreen() {
		var navigationController: UINavigationController!

		let viewController = DiaryDayNotesInfoViewController(
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)

		navigationController = NavigationControllerWithLargeTitle(rootViewController: viewController)

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
		navigationController = NavigationControllerWithLargeTitle(rootViewController: viewController)
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
