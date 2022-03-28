//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol ExposureSubmissionTestResultModel {

	var dynamicTableViewModelPublisher: OpenCombine.CurrentValueSubject<DynamicTableViewModel, Never> { get }
	var shouldShowDeletionConfirmationAlertPublisher: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	var errorPublisher: OpenCombine.CurrentValueSubject<CoronaTestServiceError?, Never> { get }
	var shouldAttemptToDismissPublisher: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	var footerViewModelPublisher: OpenCombine.CurrentValueSubject<FooterViewModel?, Never> { get }
	var title: String { get }
	var testResult: TestResult { get }

	func didTapPrimaryButton()
	func didTapSecondaryButton()
	func deleteTest()
	func evaluateShowing()
	func updateTestResultIfPossible()

}
