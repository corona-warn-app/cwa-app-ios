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

class ExposureSubmissionTestResultViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		viewModel: ExposureSubmissionTestResultViewModel,
		onContinueWithSymptomsButtonTap: @escaping () -> Void,
		onContinueWithoutSymptomsButtonTap: @escaping () -> Void,
		onTestDeleted: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onContinueWithSymptomsButtonTap = onContinueWithSymptomsButtonTap
		self.onContinueWithoutSymptomsButtonTap = onContinueWithoutSymptomsButtonTap
		self.onTestDeleted = onTestDeleted

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
	}

	override var navigationItem: UINavigationItem {
		viewModel.navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		switch viewModel.testResult {
		case .positive:
			onContinueWithSymptomsButtonTap()
		case .negative, .invalid, .expired:
			deleteTest()
		case .pending:
			refreshTest()
		}
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		switch viewModel.testResult {
		case .positive:
			onContinueWithoutSymptomsButtonTap()
		case .pending:
			deleteTest()
		default:
			// Secondary button is only active for pending result state.
			break
		}
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionTestResultViewModel

	private let onContinueWithSymptomsButtonTap: () -> Void
	private let onContinueWithoutSymptomsButtonTap: () -> Void
	private let onTestDeleted: () -> Void

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		cellBackgroundColor = .clear

		setupDynamicTableView()
		setupNavigationBar()
	}

	private func setupNavigationBar() {
		navigationItem.hidesBackButton = true
		navigationController?.navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.ExposureSubmissionResult.title
	}

	private func setupDynamicTableView() {
		tableView.separatorStyle = .none

		tableView.register(
			UINib(nibName: String(describing: ExposureSubmissionTestResultHeaderView.self), bundle: nil),
			forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.testResult.rawValue
		)
		tableView.register(
			UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

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
				self.viewModel.deleteTest()
				self.onTestDeleted()
			}
		)

		alert.addAction(delete)
		alert.addAction(cancel)

		present(alert, animated: true, completion: nil)
	}

	private func refreshTest() {
		navigationFooterItem?.isPrimaryButtonEnabled = false
		navigationFooterItem?.isPrimaryButtonLoading = true

		viewModel.refreshTest()
	}

	private func refreshView() {
		self.dynamicTableViewModel = self.viewModel.dynamicTableViewModel
		self.tableView.reloadData()
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
