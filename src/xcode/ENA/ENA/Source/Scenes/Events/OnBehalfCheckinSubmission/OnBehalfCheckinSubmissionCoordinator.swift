//
// 🦠 Corona-Warn-App
//

import UIKit

final class OnBehalfCheckinSubmissionCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController,
		restServiceProvider: RestServiceProviding,
		appConfiguration: AppConfigurationProviding,
		eventStore: EventStoringProviding,
		client: Client,
		qrScannerCoordinator: QRScannerCoordinator
	) {
		self.parentViewController = parentViewController
		self.appConfiguration = appConfiguration
		self.eventStore = eventStore
		self.client = client
		self.qrScannerCoordinator = qrScannerCoordinator

		self.checkinSubmissionService = OnBehalfCheckinSubmissionService(
			restServiceProvider: restServiceProvider,
			client: client,
			appConfigurationProvider: appConfiguration
		)
	}
	
	// MARK: - Internal

	func start() {
		navigationController = DismissHandlingNavigationController(rootViewController: infoScreen)
		navigationController.navigationBar.prefersLargeTitles = true

		parentViewController.present(navigationController, animated: true)
	}
	
	// MARK: - Private

	private weak var parentViewController: UIViewController!
	private var navigationController: DismissHandlingNavigationController!

	private let appConfiguration: AppConfigurationProviding
	private let eventStore: EventStoringProviding
	private let client: Client
	private let checkinSubmissionService: OnBehalfCheckinSubmissionService
	private let qrScannerCoordinator: QRScannerCoordinator

	private weak var traceLocationSelectionViewController: OnBehalfTraceLocationSelectionViewController?

	// MARK: Show Screens

	private lazy var infoScreen: UIViewController = {
		let infoViewController = OnBehalfInfoViewController(
			onPrimaryButtonTap: { [weak self] in
				self?.showTraceLocationSelectionScreen()
			},
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.OnBehalfCheckinSubmission.Info.primaryButtonTitle,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		return TopBottomContainerViewController(
			topController: infoViewController,
			bottomController: footerViewController
		)
	}()

	private func showTraceLocationSelectionScreen() {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(traceLocations: eventStore.traceLocationsPublisher.value)

		let traceLocationSelectionViewController = OnBehalfTraceLocationSelectionViewController(
			viewModel: viewModel,
			onScanQRCodeCellTap: { [weak self] in
				self?.showQRCodeScanner()
			},
			onPrimaryButtonTap: { [weak self] selectedTraceLocation in
				self?.showDateTimeSelectionSelectionScreen(
					traceLocation: selectedTraceLocation
				)
			},
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)
		self.traceLocationSelectionViewController = traceLocationSelectionViewController

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.primaryButtonTitle,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let containerViewController = TopBottomContainerViewController(
			topController: traceLocationSelectionViewController,
			bottomController: footerViewController
		)

		navigationController.pushViewController(containerViewController, animated: true)
	}

	private func showQRCodeScanner() {
		qrScannerCoordinator.didScanTraceLocationInOnBehalfFlow = { [weak self] traceLocation in
			self?.showDateTimeSelectionSelectionScreen(traceLocation: traceLocation)
		}

		qrScannerCoordinator.start(
			parentViewController: navigationController,
			presenter: .onBehalfFlow
		)
	}

	private func showDateTimeSelectionSelectionScreen(
		traceLocation: TraceLocation
	) {
		let dateTimeSelectionViewController = OnBehalfDateTimeSelectionViewController(
			traceLocation: traceLocation,
			onPrimaryButtonTap: { [weak self] checkin in
				self?.showTANInputScreen(
					checkin: checkin
				)
			},
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.primaryButtonTitle,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let containerViewController = TopBottomContainerViewController(
			topController: dateTimeSelectionViewController,
			bottomController: footerViewController
		)

		navigationController.pushViewController(containerViewController, animated: true)
	}

	private func showTANInputScreen(
		checkin: Checkin
	) {
		let tanInputViewModel = TanInputViewModel(
			title: AppStrings.OnBehalfCheckinSubmission.TANInput.title,
			description: AppStrings.OnBehalfCheckinSubmission.TANInput.description,
			onPrimaryButtonTap: { [weak self] teleTAN, isLoading in
				isLoading(true)

				Log.info("[OnBehalfCheckinSubmission] Submitting with TAN \(private: teleTAN)", log: .checkin)

				self?.checkinSubmissionService.submit(
					checkin: checkin,
					teleTAN: teleTAN
				) { result in
					isLoading(false)

					switch result {
					case .success:
						self?.showThankYouScreen()
					case .failure(let error):
						self?.showErrorAlert(error: error)
					}
				}
			}
		)

		let tanInputViewController = TanInputViewController(
			viewModel: tanInputViewModel,
			dismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.OnBehalfCheckinSubmission.TANInput.primaryButtonTitle,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let containerViewController = TopBottomContainerViewController(
			topController: tanInputViewController,
			bottomController: footerViewController
		)

		navigationController.pushViewController(containerViewController, animated: true)
	}

	private func showThankYouScreen() {
		let thankYouViewController = OnBehalfThankYouViewController(
			onDismiss: { [weak self] in
				self?.parentViewController.dismiss(animated: true)
			}
		)

		navigationController.pushViewController(thankYouViewController, animated: true)
	}

	private func showSettings() {
		LinkHelper.open(urlString: UIApplication.openSettingsURLString)
	}

	private func showErrorAlert(
		error: Error
	) {
		let alert = UIAlertController.errorAlert(message: error.localizedDescription)

		DispatchQueue.main.async { [weak self] in
			self?.navigationController.present(alert, animated: true, completion: nil)
		}
	}
	
}
