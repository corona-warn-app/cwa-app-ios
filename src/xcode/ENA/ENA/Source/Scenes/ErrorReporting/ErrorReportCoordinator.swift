////
// 🦠 Corona-Warn-App
//

import UIKit

protocol ErrorReportsCoordinating: class {
	func startErrorLogging()
	func stopErrorLogging()
	func sendErrorLogging()
	func exportErrorLogging()
}

final class ErrorReportsCoordinator: ErrorReportsCoordinating, RequiresAppDependencies {

	// MARK: - Init

	init(
		rootViewController: UIViewController,
		initialState: ErrorLoggingStatus = .inactive,
		ppacService: PrivacyPreservingAccessControl,
		otpService: OTPServiceProviding
	) {
		self.rootViewController = rootViewController
		self.errorLoggingStatus = initialState
		self.ppacService = ppacService
		self.otpService = otpService
	}

	// MARK: - Internal

	func start() {
		// temporary solution: the coordinator gets deallocated after the start method so when we tap a button the weak self is nil
		// the current solution to keep the instance alive is to inject a strong reference to it inside the ErrorReportLoggingViewController
		// when the user goes back to the AppInformationViewController, the ErrorReportLoggingViewController will be deallocated and the coordinator with it
		let errorReportsLoggingViewController = BottomErrorReportViewController(
			coordinator: self,
			elsService: elsService,
			didTapStartButton: { [weak self] in
				self?.startErrorLogging()
			}, didTapSaveButton: { [weak self] in
				self?.exportErrorLogging()
			}, didTapSendButton: { [weak self] in
				self?.sendErrorLogging()
			}, didTapStopAndDeleteButton: { [weak self] in
				self?.stopErrorLogging()
			}
		)
		
		let viewModel = TopErrorReportViewModel(
			didPressHistoryCell: {
				// Navigate to History screen, TO DO: Prepare the view model with the array of error logs to be displayed
				self.rootViewController.navigationController?.pushViewController(ErrorReportHistoryViewController(), animated: true)

			}, didPressPrivacyInformationCell: {
				self.showPrivacyScreen()
			}
		)
		viewModel.updateViewModel()
		topViewControllerViewModel = viewModel

		let errorReportsContainerViewController = TopBottomContainerViewController(
			topController: TopErrorReportViewController(viewModel: viewModel),
			bottomController: errorReportsLoggingViewController
		)
		self.errorReportsContainerViewController = errorReportsContainerViewController
		self.errorReportsLoggingViewController = errorReportsLoggingViewController
		
		rootViewController.navigationController?.pushViewController(errorReportsContainerViewController, animated: true)
	}
	
	// MARK: - Protocol ErrorReportsCoordinating

	func startErrorLogging() {
		elsService.startLogging()
	}
	
	func stopErrorLogging() {
		elsService.stopAndDeleteLog()
	}
	
	func sendErrorLogging() {
		showConfirmSendingScreen()
	}

	func exportErrorLogging() {
		guard let item = elsService.fetchExistingLog() else {
			Log.warning("No logs to export", log: .localData)
			return
		}

		// share sheet
		let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
		activityViewController.modalTransitionStyle = .coverVertical
		rootViewController.present(activityViewController, animated: true, completion: nil)
	}
	
	// MARK: - Private
	
	private let rootViewController: UIViewController
	private let ppacService: PrivacyPreservingAccessControl
	private let otpService: OTPServiceProviding
	
	private var errorLoggingStatus: ErrorLoggingStatus
	// We need a reference to update the error logs size as we are on the screen by calling
	private var errorReportsLoggingViewController: BottomErrorReportViewController?
	/*
	We need a reference to the TopBottomContainerViewController so we can adjust the
	height of the bottom view depending on the Logging status: active or inactive
	because the active status has 2 extra buttons so the height is variable
	*/
	private var errorReportsContainerViewController: TopBottomContainerViewController <TopErrorReportViewController, BottomErrorReportViewController>?
	/*
	We need to call the update() function inside this topViewControllerViewModel every time we show the main Controller
	This insures that we show the correct number of Cells in the TopErrorReportViewController "based on wether there is already a history or not"
	i.e If a history Cell should be added or not
	*/
	private var topViewControllerViewModel: TopErrorReportViewModel?

	/// Reference to the ELS server handling error log recording & submission
	private lazy var elsService: ErrorLogHandling & ErrorLogSubmitting = ErrorLogSubmissionService(
		client: client,
		store: store,
		ppacService: ppacService,
		otpService: otpService
	)
	
	private func showConfirmSendingScreen() {
		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ErrorReport.sendReportsButtonTitle,
			primaryIdentifier: AccessibilityIdentifiers.ErrorReport.agreeAndSendButton,
			isSecondaryButtonHidden: true
		)
		let bottomViewController = FooterViewController(
			footerViewModel,
			didTapPrimaryButton: {
				self.elsService.submit { result in
					switch result {
					case .success(let response):
						debugPrint(response)
						// IDs, etc.
					case .failure(let error):
						Log.error("ELS submission error: \(error)", log: .api, error: error)
						// ...
					}

					// TODO: handle this properly!
					self.rootViewController.navigationController?.popViewController(animated: true)
					self.topViewControllerViewModel?.updateViewModel(isHistorySectionIncluded: true)
				}
			},
			didTapSecondaryButton: { }
		)
		let topViewController = SendErrorLogsViewController(
			model: SendErrorLogsViewModel(
				didPressDetailsButton: {
					self.rootViewController.navigationController?.pushViewController(ErrorReportDetailInformationViewController(), animated: true)
				}
			)
		)
		let topBottomViewController = TopBottomContainerViewController(
			topController: topViewController,
			bottomController: bottomViewController
		)
		
		rootViewController.navigationController?.pushViewController(topBottomViewController, animated: true)
	}
	
	private func showPrivacyScreen() {
		let htmlViewController = HTMLViewController(model: AppInformationModel.privacyModel)
		htmlViewController.title = AppStrings.AppInformation.privacyNavigation
		rootViewController.navigationController?.pushViewController(htmlViewController, animated: true)
	}
}
