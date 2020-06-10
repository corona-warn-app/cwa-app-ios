// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import UIKit

class ExposureSubmissionTestResultViewController: DynamicTableViewController, SpinnerInjectable {
	// MARK: - Attributes.

	var exposureSubmissionService: ExposureSubmissionService?
	var testResult: TestResult?
	var timeStamp: Int64?
	var spinner: UIActivityIndicatorView?

	// MARK: - View Lifecycle methods.

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupButtons()
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
		switch Segue(segue) {
		case .warnOthers:
			let destination = segue.destination as? ExposureSubmissionWarnOthersViewController
			destination?.exposureSubmissionService = exposureSubmissionService
		default:
			return
		}
	}

	// MARK: - View Setup Helper methods.

	private func setupView() {
		setupDynamicTableView()
		setupNavigationBar()
		timeStamp = exposureSubmissionService?.devicePairingSuccessfulTimestamp
	}

	private func setupButtons() {
		guard let result = testResult else { return }
		switch result {
		case .positive:
			setButtonTitle(to: AppStrings.ExposureSubmissionResult.continueButton)
			hideSecondaryButton()
		case .negative, .invalid:
			setButtonTitle(to: AppStrings.ExposureSubmissionResult.deleteButton)
			hideSecondaryButton()
		case .pending:
			setButtonTitle(to: AppStrings.ExposureSubmissionResult.refreshButton)
			setSecondaryButtonTitle(to: AppStrings.ExposureSubmissionResult.deleteButton)
			showSecondaryButton()
		}
	}

	private func setupNavigationBar() {
		navigationItem.hidesBackButton = true
		navigationController?.navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.ExposureSubmissionResult.title
	}

	private func setupDynamicTableView() {
		guard let result = testResult else {
			logError(message: "No test result.", level: .error)
			return
		}

		tableView.register(
			ExposureSubmissionTestResultHeaderView.self,
			forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.testResult.rawValue
		)
		tableView.register(
			UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue
		)

		dynamicTableViewModel = dynamicTableViewModel(for: result)
	}

	// MARK: - Convenience methods for buttons.

	private func deleteTest() {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmissionResult.removeAlert_Title,
			message: AppStrings.ExposureSubmissionResult.removeAlert_Text,
			preferredStyle: .alert
		)

		let cancel = UIAlertAction(
			title: AppStrings.Common.alertActionCancel,
			style: .cancel,
			handler: { _ in alert.dismiss(animated: true, completion: nil) }
		)

		let delete = UIAlertAction(
			title: AppStrings.Common.alertActionRemove,
			style: .destructive,
			handler: { _ in
				self.exposureSubmissionService?.deleteTest()
				self.navigationController?.dismiss(animated: true, completion: nil)
			}
		)

		alert.addAction(delete)
		alert.addAction(cancel)

		present(alert, animated: true, completion: nil)
	}

	private func refreshTest() {
		startSpinner()
		exposureSubmissionService?
			.getTestResult { result in
				self.stopSpinner()
				switch result {
				case let .failure(error):
					let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
					self.present(alert, animated: true, completion: nil)
				case let .success(testResult):
					self.refreshView(for: testResult)
				}
			}
	}

	private func refreshView(for result: TestResult) {
		self.testResult = result
		self.dynamicTableViewModel = self.dynamicTableViewModel(for: result)
		self.tableView.reloadData()
		self.setupButtons()
	}

	/// Only show the "warn others" screen if the ENManager is enabled correctly,
	/// otherwise, show an alert.
	private func showWarnOthers() {
		if let state = exposureSubmissionService?.preconditions() {
			if !state.isGood {
				let alert = ExposureSubmissionViewUtils.setupErrorAlert(.enNotEnabled)
				self.present(alert, animated: true, completion: nil)
				return
			}
			performSegue(withIdentifier: Segue.warnOthers, sender: self)
		}
	}
}

// MARK: - Custom Segues.

extension ExposureSubmissionTestResultViewController {
	enum Segue: String, SegueIdentifier {
		case warnOthers = "warnOthersSegue"
	}
}

// MARK: - Custom HeaderReuseIdentifiers.

extension ExposureSubmissionTestResultViewController {
	enum HeaderReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case testResult = "testResultCell"
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionTestResultViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}

// MARK: ExposureSubmissionNavigationControllerChild methods.

extension ExposureSubmissionTestResultViewController: ExposureSubmissionNavigationControllerChild {
	func didTapButton() {
		guard let result = testResult else { return }

		switch result {
		case .positive:
			showWarnOthers()
		case .negative, .invalid:
			deleteTest()
		case .pending:
			refreshTest()
		}
	}

	func didTapSecondButton() {
		guard let result = testResult else { return }
		switch result {
		case .pending:
			deleteTest()
		default:
			// Secondary button is only active for pending result state.
			break
		}
	}
}

// MARK: - DynamicTableViewModel convenience setup methods.

private extension ExposureSubmissionTestResultViewController {
	private func dynamicTableViewModel(for result: TestResult) -> DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				testResultSection(for: result)
			)
		}
	}

	private func testResultSection(for result: TestResult) -> DynamicSection {
		switch result {
		case .positive:
			return positiveTestResultSection()
		case .negative:
			return negativeTestResultSection()
		case .invalid:
			return invalidTestResultSection()
		case .pending:
			return pendingTestResultSection()
		}
	}

	private func positiveTestResultSection() -> DynamicSection {
		.section(
			header: .identifier(
				ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
				configure: { view, _ in
					(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .positive, timeStamp: self.timeStamp)
				}
			),
			separators: false,
			cells: [
				.title2(text: AppStrings.ExposureSubmissionResult.procedure,
						accessibilityIdentifier: "AppStrings.ExposureSubmissionResult.procedure"),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testAdded,
					description: AppStrings.ExposureSubmissionResult.testAddedDesc,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testPositive,
					description: AppStrings.ExposureSubmissionResult.testPositiveDesc,
					icon: UIImage(named: "Icons_Grey_Error"),
					hairline: .topAttached
				),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.warnOthers,
					description: AppStrings.ExposureSubmissionResult.warnOthersDesc,
					icon: UIImage(named: "Icons_Grey_Warnen"),
					hairline: .none
				)
			]
		)
	}

	private func negativeTestResultSection() -> DynamicSection {
		.section(
			header: .identifier(
				ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
				configure: { view, _ in
					(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .negative, timeStamp: self.timeStamp)
				}
			),
			separators: false,
			cells: [
				.title2(text: AppStrings.ExposureSubmissionResult.procedure,
						accessibilityIdentifier: "AppStrings.ExposureSubmissionResult.procedure"),


				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testAdded,
					description: AppStrings.ExposureSubmissionResult.testAddedDesc,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testNegative,
					description: AppStrings.ExposureSubmissionResult.testNegativeDesc,
					icon: UIImage(named: "Icons_Grey_Error"),
					hairline: .topAttached
				),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testRemove,
					description: AppStrings.ExposureSubmissionResult.testRemoveDesc,
					icon: UIImage(named: "Icons_Grey_Entfernen"),
					hairline: .none
				),

				.title2(text: AppStrings.ExposureSubmissionResult.furtherInfos_Title,
						accessibilityIdentifier: "AppStrings.ExposureSubmissionResult.furtherInfos_Title"),

				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem1),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem2),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem3),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionResult.furtherInfos_TestAgain)
			]
		)
	}

	private func invalidTestResultSection() -> DynamicSection {
		.section(
			header: .identifier(
				ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
				configure: { view, _ in
					(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .invalid, timeStamp: self.timeStamp)
				}
			),
			separators: false,
			cells: [
				.title2(text: AppStrings.ExposureSubmissionResult.procedure,
						accessibilityIdentifier: "AppStrings.ExposureSubmissionResult.procedure"),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testAdded,
					description: AppStrings.ExposureSubmissionResult.testAddedDesc,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testInvalid,
					description: AppStrings.ExposureSubmissionResult.testInvalidDesc,
					icon: UIImage(named: "Icons_Grey_Error"),
					hairline: .topAttached
				),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testRemove,
					description: AppStrings.ExposureSubmissionResult.testRemoveDesc,
					icon: UIImage(named: "Icons_Grey_Entfernen"),
					hairline: .none
				)
			]
		)
	}

	private func pendingTestResultSection() -> DynamicSection {
		.section(
			header: .identifier(
				ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
				configure: { view, _ in
					(view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .pending, timeStamp: self.timeStamp)
				}
			),
			cells: [
				.title2(text: AppStrings.ExposureSubmissionResult.procedure,
						accessibilityIdentifier: "AppStrings.ExposureSubmissionResult.procedure"),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testAdded,
					description: AppStrings.ExposureSubmissionResult.testAddedDesc,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				),

				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.testPending,
					description: AppStrings.ExposureSubmissionResult.testPendingDesc,
					icon: UIImage(named: "Icons_Grey_Wait"),
					hairline: .none
				)
			]
		)
	}
}
