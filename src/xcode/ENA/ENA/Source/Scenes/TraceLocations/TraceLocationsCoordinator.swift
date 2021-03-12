//
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationsCoordinator {

	// MARK: - Init

	init(
		store: Store,
		eventStore: EventStoring & EventProviding,
		parentNavigationController: UINavigationController
	) {
		self.store = store
		self.eventStore = eventStore
		self.parentNavigationController = parentNavigationController
	}

	// MARK: - Internal

	func start() {

//		let testViewController = UITableViewController()
//		testViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Test", style: .plain, target: self, action: nil)
//		parentNavigationController?.pushViewController(testViewController, animated: true)
		parentNavigationController?.pushViewController(overviewScreen, animated: true)

		eventStore.createTraceLocation(TraceLocation(guid: "1234", version: 0, type: .type1, description: "Jahrestreffen der deutschen SAP Anwendergruppe", address: "Hauptstr 3, 69115 Heidelberg", startDate: Date(timeIntervalSince1970: 1506432400), endDate: Date(timeIntervalSince1970: 1615557969), defaultCheckInLengthInMinutes: 30, signature: ""))

		#if DEBUG
		if isUITesting {
			if let TraceLocationsInfoScreenShown = UserDefaults.standard.string(forKey: "TraceLocationsInfoScreenShown") {
				store.traceLocationsInfoScreenShown = (TraceLocationsInfoScreenShown != "NO")
			}

		}
		#endif

		if !infoScreenShown {
			showInfoScreen()
		}
	}

	// MARK: - Private

	private let store: Store
	private let eventStore: EventStoring & EventProviding

	private weak var parentNavigationController: UINavigationController?

	private var traceLocationDetailsNavigationController: ENANavigationControllerWithFooter!
	private var traceLocationAddingNavigationController: ENANavigationControllerWithFooter!

	private var infoScreenShown: Bool {
		get { store.traceLocationsInfoScreenShown }
		set { store.traceLocationsInfoScreenShown = newValue }
	}

	// MARK: Show Screens

	private lazy var overviewScreen: UIViewController = {

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.TraceLocations.Information.primaryButtonTitle,
			isSecondaryButtonEnabled: false,
			isPrimaryButtonHidden: true,
			isSecondaryButtonHidden: true,
			primaryButtonColor: .red
		)

		let traceLocationsOverviewViewController = TraceLocationsOverviewViewController(
			viewModel: TraceLocationsOverviewViewModel(
				store: eventStore,
				onAddEntryCellTap: { [weak self] in
					self?.showTraceLocationTypeSelectionScreen()
				},
				onEntryCellTap: { [weak self] traceLocation in
					self?.showTraceLocationDetailsScreen(traceLocation: traceLocation)
				},
				onEntryCellButtonTap: { [weak self] traceLocation in
					self?.showCheckInScreen(traceLocation: traceLocation)
				}
			),
			onInfoButtonTap: { [weak self] in
				self?.showInfoScreen()
			}
		)

		let footerViewController = FooterViewController(
			footerViewModel,
			didTapPrimaryButton: {
				Log.debug("NYD - tap delete all button")
			}
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationsOverviewViewController,
			bottomController: footerViewController,
			viewModel: footerViewModel
		)

		return topBottomContainerViewController
	}()

	private func showInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let traceLocationsInfoViewController = TraceLocationsInfoViewController(
			viewModel: TraceLocationsInfoViewModel(
				presentDisclaimer: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					// hides the footer view as well
					detailViewController.hidesBottomBarWhenPushed = true
					navigationController.pushViewController(detailViewController, animated: true)
				}
			),
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.TraceLocations.Information.primaryButtonTitle,
			isSecondaryButtonEnabled: false,
			isSecondaryButtonHidden: true
		)

		let footerViewController = FooterViewController(
			footerViewModel,
			didTapPrimaryButton: {
				navigationController.dismiss(animated: true)
			}
		)

		let topBottomLayoutViewController = TopBottomContainerViewController(
			topController: traceLocationsInfoViewController,
			bottomController: footerViewController,
			viewModel: footerViewModel
		)
		navigationController = UINavigationController(rootViewController: topBottomLayoutViewController)
		
		parentNavigationController?.present(navigationController, animated: true) {
			self.infoScreenShown = true
		}
	}

	private func showTraceLocationDetailsScreen(traceLocation: TraceLocation) {
		let viewController = TraceLocationDetailsViewController(
			viewModel: TraceLocationDetailsViewModel(traceLocation: traceLocation),
			onPrintVersionButtonTap: { [weak self] traceLocation in
				self?.showPrintVersionScreen(traceLocation: traceLocation)
			},
			onDuplicateButtonTap: { [weak self] traceLocation in
				guard let self = self else { return }

				self.showTraceLocationConfigurationScreen(
					on: self.traceLocationDetailsNavigationController,
					mode: .duplicate(traceLocation)
				)
			},
			onDismiss: { [weak self] in
				self?.traceLocationDetailsNavigationController.dismiss(animated: true)
			}
		)

		traceLocationDetailsNavigationController = ENANavigationControllerWithFooter(rootViewController: viewController)
		parentNavigationController?.present(traceLocationDetailsNavigationController, animated: true)
	}

	private func showPrintVersionScreen(traceLocation: TraceLocation) {
		let viewController = TraceLocationPrintVersionViewController(
			viewModel: TraceLocationPrintVersionViewModel(traceLocation: traceLocation)
		)

		traceLocationDetailsNavigationController.pushViewController(viewController, animated: true)
	}

	private func showTraceLocationTypeSelectionScreen() {
		let viewController = TraceLocationTypeSelectionViewController(
			viewModel: TraceLocationTypeSelectionViewModel(
				onTraceLocationTypeSelection: { [weak self] traceLocationType in
					guard let self = self else { return }

					self.showTraceLocationConfigurationScreen(
						on: self.traceLocationAddingNavigationController,
						mode: .new(traceLocationType)
					)
				}
			),
			onDismiss: { [weak self] in
				self?.traceLocationAddingNavigationController.dismiss(animated: true)
			}
		)

		traceLocationAddingNavigationController = ENANavigationControllerWithFooter(rootViewController: viewController)
		parentNavigationController?.present(traceLocationAddingNavigationController, animated: true)
	}

	private func showTraceLocationConfigurationScreen(on navigationController: UINavigationController, mode: TraceLocationConfigurationViewModel.Mode) {
		let viewController = TraceLocationConfigurationViewController(
			viewModel: TraceLocationConfigurationViewModel(mode: mode),
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)

		navigationController.pushViewController(viewController, animated: true)
	}

	private func showCheckInScreen(traceLocation: TraceLocation) {

	}

}
