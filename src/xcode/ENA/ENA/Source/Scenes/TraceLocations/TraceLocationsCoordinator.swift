//
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationsCoordinator {

	// MARK: - Init

	init(
		store: Store,
		parentNavigationController: UINavigationController
	) {
		self.store = store
		self.parentNavigationController = parentNavigationController
	}

	// MARK: - Internal

	func start() {
		parentNavigationController?.pushViewController(overviewScreen, animated: true)

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

	private weak var parentNavigationController: UINavigationController?

	private var traceLocationDetailsNavigationController: ENANavigationControllerWithFooter!
	private var traceLocationAddingNavigationController: ENANavigationControllerWithFooter!

	private var infoScreenShown: Bool {
		get { store.traceLocationsInfoScreenShown }
		set { store.traceLocationsInfoScreenShown = newValue }
	}

	// MARK: Show Screens

	private lazy var overviewScreen: TraceLocationsOverviewViewController = {
		return TraceLocationsOverviewViewController(
			viewModel: TraceLocationsOverviewViewModel(
				onAddEntryCellTap: { [weak self] in
					self?.showTraceLocationTypeSelectionScreen()
				},
				onEntryCellTap: { [weak self] traceLocation in
					self?.showTraceLocationDetailsScreen(traceLocation: traceLocation)
				},
				onSelfCheckInButtonTap: { [weak self] traceLocation in
					self?.showSelfCheckInScreen(traceLocation: traceLocation)
				}
			)
		)
	}()

	private func showInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: ENANavigationControllerWithFooter!
		let viewController = TraceLocationsInfoViewController(
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
		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = ENANavigationControllerWithFooter(rootViewController: viewController)
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

	private func showSelfCheckInScreen(traceLocation: TraceLocation) {

	}

}
