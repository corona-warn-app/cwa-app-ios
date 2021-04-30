////
// 🦠 Corona-Warn-App
//

import UIKit

protocol ErrorReportsCoordinating: AnyObject {
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
		
		#if DEBUG
		if isUITesting {
			// This ensures, that for any UI Test that sets the launch arguement, the logging is disabled (so that for example the test can start logging).
			if let shouldElsLogginActive = UserDefaults.standard.string(forKey: "elsLogActive"),
			   shouldElsLogginActive == "NO" {
				do {
					try elsService.stopAndDeleteLog()
				} catch {
					Log.warning("Could not stop ELS logging due to error: \(error)")
				}
			}
			
			// This ensures, that for any UI Test that sets the launch arguement, we create some history entries so that we simulate a succesfull els submission before.
			if let journalRemoveAllPersons = UserDefaults.standard.string(forKey: "elsCreateFakeHistory"),
			   journalRemoveAllPersons == "YES" {
				var items = self.store.elsUploadHistory
				items.append(ErrorLogUploadReceipt(id: "FakeReceiptID001", timestamp: Date()))
				items.append(ErrorLogUploadReceipt(id: "FakeReceiptID002", timestamp: Date()))
				var store = self.store // quick hack to allow writing
				store.elsUploadHistory = items
			}
		}
		#endif
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
				// Navigate to History screen
				self.rootViewController.navigationController?
					.pushViewController(ErrorReportHistoryViewController(store: self.store), animated: true)

			}, didPressPrivacyInformationCell: {
				self.showPrivacyScreen()
			}
		)
		viewModel.updateViewModel(isHistorySectionIncluded: !store.elsUploadHistory.isEmpty)
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
		do {
			try elsService.stopAndDeleteLog()
		} catch {
			showErrorAlert(with: error)
		}
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
				// can't disable buttons while this is running
				self.elsService.submit { [weak self] result in
					guard let self = self else {
						Log.error("Could not create strong self")
						return
					}
					switch result {
					case .success(let response):
						// Let's make history ;)
						var items = self.store.elsUploadHistory
						items.append(ErrorLogUploadReceipt(id: response.id, timestamp: Date()))
						var store = self.store // quick hack to allow writing
						store.elsUploadHistory = items

						Log.info("ELS log submitted successfully", log: .els)
						self.rootViewController.navigationController?.popViewController(animated: true)
						self.topViewControllerViewModel?.updateViewModel(isHistorySectionIncluded: true)
					case .failure(let error):
						Log.error("ELS submission error: \(error)", log: .els, error: error)
						self.showErrorAlert(with: error)
					}
				}
			},
			didTapSecondaryButton: { /* no op */ }
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

	private func showErrorAlert(with error: Error) {
		let alert = UIAlertController(title: AppStrings.Common.alertTitleGeneral, message: error.localizedDescription, preferredStyle: .alert)
		let okAction = UIAlertAction(title: AppStrings.Common.alertActionOk, style: .default, handler: { _ in
			alert.dismiss(animated: true, completion: nil)
		})
		alert.addAction(okAction)
		DispatchQueue.main.async {
			self.rootViewController.present(alert, animated: true, completion: nil)
		}
	}
}
