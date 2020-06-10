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

import UIKit

class ExposureSubmissionIntroViewController: DynamicTableViewController, ExposureSubmissionNavigationControllerChild, SpinnerInjectable {

	// MARK: - Attributes.
	
	private var exposureSubmissionService: ExposureSubmissionService?
	var spinner: UIActivityIndicatorView?

	// MARK: - View lifecycle methods.

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// The button is shared among multiple controllers,
		// make sure to reset it whenever the view appears.
		setButtonTitle(to: AppStrings.ExposureSubmission.continueText)
		if exposureSubmissionService?.hasRegistrationToken() ?? false {
			fetchResult()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupBackButton()

		// Grab ExposureSubmissionService from the navigation controller
		// (which is the entry point for the storyboard, and in which
		// this controller is embedded.)
		if let navC = navigationController as? ExposureSubmissionNavigationController {
			exposureSubmissionService = navC.getExposureSubmissionService()
		}
	}

	// MARK: - Setup helpers.

	private func setupView() {
		setupTitle()
		setupTableView()
	}

	private func setupTitle() {
		navigationItem.largeTitleDisplayMode = .always
		title = AppStrings.ExposureSubmissionIntroduction.title
	}

	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
		
		dynamicTableViewModel = .intro
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch Segue(segue) {
		case .labResult:
			let destination = segue.destination as? ExposureSubmissionTestResultViewController
			destination?.exposureSubmissionService = exposureSubmissionService
			destination?.testResult = sender as? TestResult
		default:
			break
		}
	}

	// MARK: - ExposureSubmissionNavigationControllerChild methods.

	func didTapButton() {
		performSegue(withIdentifier: Segue.overview, sender: self)
	}

	// MARK: - Helpers.
	private func fetchResult() {
		startSpinner()
		exposureSubmissionService?.getTestResult { result in
			self.stopSpinner()
			switch result {
			case let .failure(error):
				logError(message: "An error occurred during result fetching: \(error)", level: .error)
				let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
				self.present(alert, animated: true, completion: nil)
			case let .success(testResult):
				self.performSegue(withIdentifier: Segue.labResult, sender: testResult)
			}
		}
	}
}

private extension DynamicTableViewModel {
	static let intro = DynamicTableViewModel([
		.navigationSubtitle(text: AppStrings.ExposureSubmissionIntroduction.subTitle,
							accessibilityIdentifier: "AppStrings.ExposureSubmissionIntroduction.subTitle"),
		.section(
			header: .image(
				UIImage(named: "Illu_Submission_Funktion1"),
				accessibilityLabel: nil,
				accessibilityIdentifier: nil,
				height: 200
			),
			separators: false,
			cells: [
				.headline(text: AppStrings.ExposureSubmissionIntroduction.usage01,
						  accessibilityIdentifier: "AppStrings.ExposureSubmissionIntroduction.usage01"),
				.body(text: AppStrings.ExposureSubmissionIntroduction.usage02,
					  accessibilityIdentifier: "AppStrings.ExposureSubmissionIntroduction.usage02"),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionIntroduction.listItem1),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionIntroduction.listItem2),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionIntroduction.listItem3),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionIntroduction.listItem4)
			]
		)
	])
}

private extension ExposureSubmissionIntroViewController {
	enum Segue: String, SegueIdentifiers {
		case overview = "overviewSegue"
		case labResult = "labResultSegue"
	}
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}
