//
// 🦠 Corona-Warn-App
//

import UIKit

final class OnBehalfCheckinSubmissionCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController,
		appConfiguration: AppConfigurationProviding,
		eventStore: EventStoringProviding,
		client: Client
	) {
		self.parentViewController = parentViewController
		self.appConfiguration = appConfiguration
		self.eventStore = eventStore
		self.client = client
	}
	
	// MARK: - Internal

	func start() {
		navigationController = DismissHandlingNavigationController(rootViewController: infoScreen)
		parentViewController.present(navigationController, animated: true)
	}
	
	// MARK: - Private

	private weak var parentViewController: UIViewController!
	private var navigationController: DismissHandlingNavigationController!

	private let appConfiguration: AppConfigurationProviding
	private let eventStore: EventStoringProviding
	private let client: Client

	private var traceLocationSelectionViewModel: OnBehalfTraceLocationSelectionViewModel?

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
		traceLocationSelectionViewModel = viewModel

		let traceLocationSelectionViewController = OnBehalfTraceLocationSelectionViewController(
			viewModel: viewModel,
			onScanQRCodeCellTap: { [weak self] in
				self?.showQRCodeScanner()
			},
			onMissingPermissionsButtonTap: { [weak self] in
				self?.showSettings()
			},
			onCompletion: { [weak self] selectedTraceLocation in
				self?.showDateTimeSelectionSelectionScreen(
					traceLocation: selectedTraceLocation
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
			topController: traceLocationSelectionViewController,
			bottomController: footerViewController
		)

		navigationController.pushViewController(containerViewController, animated: true)
	}

	func showQRCodeScanner() {
		let qrCodeScanner = CheckinQRCodeScannerViewController(
			qrCodeVerificationHelper: QRCodeVerificationHelper(),
			appConfiguration: appConfiguration,
			didScanCheckin: { [weak self] traceLocation in
				self?.navigationController.dismiss(animated: true) {
					self?.showDateTimeSelectionSelectionScreen(traceLocation: traceLocation)
				}
			},
			dismiss: { [weak self] in
				self?.traceLocationSelectionViewModel?.updateForCameraPermission()
				self?.navigationController.dismiss(animated: true)
			}
		)

		qrCodeScanner.definesPresentationContext = true
		DispatchQueue.main.async { [weak self] in
			let navigationController = UINavigationController(rootViewController: qrCodeScanner)
			navigationController.modalPresentationStyle = .fullScreen
			self?.navigationController.present(navigationController, animated: true)
		}
	}

	private func showDateTimeSelectionSelectionScreen(
		traceLocation: TraceLocation
	) {

	}

	private func showTANInputScreen(
		checkin: Checkin
	) {

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
		title: String,
		error: Error
	) {
		let alert = UIAlertController(
			title: title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)

		let okayAction = UIAlertAction(
			title: AppStrings.Common.alertActionOk,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)
		alert.addAction(okayAction)
		DispatchQueue.main.async { [weak self] in
			self?.navigationController.present(alert, animated: true, completion: nil)
		}
	}
	
}
