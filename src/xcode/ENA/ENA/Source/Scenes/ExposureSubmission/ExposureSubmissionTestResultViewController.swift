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
    var spinner: UIActivityIndicatorView?

    // MARK: - View Lifecycle methods.

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.navigationBar.sizeToFit()
        }
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
        setupButton()
    }

    private func setupButton() {
        guard let result = testResult else { return }
        switch result {
        case .positive:
            setButtonTitle(to: AppStrings.ExposureSubmissionResult.continueButton)
        case .negative, .invalid, .pending:
            setButtonTitle(to: AppStrings.ExposureSubmissionResult.deleteButton)
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

        tableView.register(ExposureSubmissionTestResultHeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.testResult.rawValue)
        dynamicTableViewModel = dynamicTableViewModel(for: result)
    }

    // MARK: - Convenience methods for buttons.

    private func deleteTest() {
        exposureSubmissionService?.deleteTest()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    private func showWarnOthers() {
        performSegue(withIdentifier: Segue.warnOthers, sender: self)
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

// MARK: ExposureSubmissionNavigationControllerChild methods.

extension ExposureSubmissionTestResultViewController: ExposureSubmissionNavigationControllerChild {
    func didTapBottomButton() {
        guard let result = testResult else { return }

        switch result {
        case .positive:
            showWarnOthers()
        case .negative, .invalid:
            deleteTest()
        default:
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
        default:
            return .section(cells: [])
        }
    }

    private func positiveTestResultSection() -> DynamicSection {
        .section(
            header: .identifier(ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
                                configure: { view, _ in
                                    (view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .positive)
								}),
            separators: false,
            cells: [
                .bigBold(text: AppStrings.ExposureSubmissionResult.procedure),
                .semibold(text: AppStrings.ExposureSubmissionResult.testAdded),
                .regular(text: AppStrings.ExposureSubmissionResult.testAddedDesc),
                .semibold(text: AppStrings.ExposureSubmissionResult.testPositive),
                .regular(text: AppStrings.ExposureSubmissionResult.testPositiveDesc),
                .semibold(text: AppStrings.ExposureSubmissionResult.warnOthers),
                .regular(text: AppStrings.ExposureSubmissionResult.warnOthersDesc)
            ]
        )
    }

    private func negativeTestResultSection() -> DynamicSection {
        .section(
            header: .identifier(ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
                                configure: { view, _ in
                                    (view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .negative)
								}),
            separators: false,
            cells: [
                .bigBold(text: AppStrings.ExposureSubmissionResult.procedure),
                .semibold(text: AppStrings.ExposureSubmissionResult.testAdded),
                .regular(text: AppStrings.ExposureSubmissionResult.testAddedDesc),
                .semibold(text: AppStrings.ExposureSubmissionResult.testNegative),
                .regular(text: AppStrings.ExposureSubmissionResult.testNegativeDesc)
            ]
        )
    }

    private func invalidTestResultSection() -> DynamicSection {
        .section(
            header: .identifier(ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.testResult,
                                configure: { view, _ in
                                    (view as? ExposureSubmissionTestResultHeaderView)?.configure(testResult: .invalid)
								}),
            separators: false,
            cells: [
                .bigBold(text: AppStrings.ExposureSubmissionResult.procedure),
                .semibold(text: AppStrings.ExposureSubmissionResult.testAdded),
                .regular(text: AppStrings.ExposureSubmissionResult.testAddedDesc),
                .semibold(text: AppStrings.ExposureSubmissionResult.testInvalid),
                .regular(text: AppStrings.ExposureSubmissionResult.testInvalidDesc)
            ]
        )
    }
}
