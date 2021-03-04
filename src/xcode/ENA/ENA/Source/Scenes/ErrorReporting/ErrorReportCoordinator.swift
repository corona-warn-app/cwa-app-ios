////
// 🦠 Corona-Warn-App
//

import UIKit

protocol ErrorReportsCoordinating: class {
	func startErrorLogging()
	func stopErrorLogging()
	func sendErrorLogging()
	func saveErrorLogging()
}

final class ErrorReportsCoordinator: ErrorReportsCoordinating {

	// MARK: - Init

	init(rootViewController: UIViewController, initialState: ErrorLoggingStatus = .inactive) {
		self.rootViewController = rootViewController
		self.errorLoggingStatus = initialState
	}

	// MARK: - Internal

	func start() {
		// temporary solution: the coordinator gets deallocated after the start method so when we tap a button the weak self is nil
		// the current solution to keep the instance alive is to inject a strong reference to it inside the ErrorReportLoggingViewController
		// when the user goes back to the AppInformationViewController, the ErrorReportLoggingViewController will be deallocated and the coordinator with it
		let errorReportsLoggingViewController = ErrorReportLoggingViewController(
			coordinator: self,
			didTapStartButton: { [weak self] in
				self?.startErrorLogging()
			}, didTapSaveButton: { [weak self] in
				self?.saveErrorLogging()
			}, didTapSendButton: { [weak self] in
				self?.sendErrorLogging()
			}, didTapStopAndDeleteButton: { [weak self] in
				self?.stopErrorLogging()
			}
		)
		let errorReportsContainerViewController = TopBottomContainerViewController(
			topController: ErrorReportViewController(),
			bottomController: errorReportsLoggingViewController,
			bottomHeight: errorLoggingStatus.bottomViewHeight
		)
		self.errorReportsContainerViewController = errorReportsContainerViewController
		self.errorReportsLoggingViewController = errorReportsLoggingViewController
		
		rootViewController.navigationController?.pushViewController(errorReportsContainerViewController, animated: true)
	}
	
	// MARK: - Protocol ErrorReportsCoordinating

	func startErrorLogging() {
		errorReportsContainerViewController?.updateBottomHeight(to: ErrorLoggingStatus.active.bottomViewHeight)
		// Add here Collection of Logs
	}
	
	func stopErrorLogging() {
		errorReportsContainerViewController?.updateBottomHeight(to: ErrorLoggingStatus.inactive.bottomViewHeight)
		// Add here deletion of the collected logs
	}
	
	func sendErrorLogging() {
		// Add here navigation to the consent with the legal text
	}
	
	func saveErrorLogging() {
		// Add here saving the logs to the file manager
		// TO DO navigate to the ErrorReportDetailInformationViewController from the sendingViewController after implementing it
		rootViewController.navigationController?.pushViewController(ErrorReportDetailInformationViewController(), animated: true)
	}
	
	// MARK: - Private
	
	private let rootViewController: UIViewController
	private var errorLoggingStatus: ErrorLoggingStatus

	// We need a reference to update the error logs size as we are on the screen by calling
	private var errorReportsLoggingViewController: ErrorReportLoggingViewController?
	
	/*
	We need a reference to the TopBottomContainerViewController so we can adjust the
	height of the bottom view depending on the Logging status: active or inactive
	because the active status has 2 extra buttons so the height is variable
	*/
	private var errorReportsContainerViewController: TopBottomContainerViewController <ErrorReportViewController, ErrorReportLoggingViewController>?
}
