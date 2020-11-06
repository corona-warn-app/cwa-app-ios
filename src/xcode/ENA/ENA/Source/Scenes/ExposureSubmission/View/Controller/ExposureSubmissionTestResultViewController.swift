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
import Combine

class ExposureSubmissionTestResultViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		viewModel: ExposureSubmissionTestResultViewModel
	) {
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpView()
		setUpBindings()
	}

	override var navigationItem: UINavigationItem {
		viewModel.navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.didTapPrimaryButton()
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		viewModel.didTapSecondaryButton()
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionTestResultViewModel

	private var bindings: [AnyCancellable] = []

	private func setUpView() {
		view.backgroundColor = .enaColor(for: .background)
		cellBackgroundColor = .clear

		setUpDynamicTableView()
	}

	private func setUpDynamicTableView() {
		tableView.separatorStyle = .none

		tableView.register(
			UINib(nibName: String(describing: ExposureSubmissionTestResultHeaderView.self), bundle: nil),
			forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.testResult.rawValue
		)
		tableView.register(
			UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue
		)
	}

	private func setUpBindings() {
		viewModel.$dynamicTableViewModel
			.sink { [weak self] dynamicTableViewModel in
				self?.dynamicTableViewModel = dynamicTableViewModel
				self?.tableView.reloadData()
			}
			.store(in: &bindings)

		viewModel.$shouldShowDeletionConfirmationAlert
			.sink { [weak self] shouldShowDeletionConfirmationAlert in
				guard let self = self, shouldShowDeletionConfirmationAlert else { return }

				self.viewModel.shouldShowDeletionConfirmationAlert = false

				self.showDeletionConfirmationAlert()
			}
			.store(in: &bindings)

		viewModel.$error
			.sink { [weak self] error in
				guard let self = self, let error = error else { return }

				self.viewModel.error = nil

				let alert = self.setupErrorAlert(message: error.localizedDescription)
				self.present(alert, animated: true)
			}
			.store(in: &bindings)
	}

	private func showDeletionConfirmationAlert() {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmissionResult.removeAlert_Title,
			message: AppStrings.ExposureSubmissionResult.removeAlert_Text,
			preferredStyle: .alert
		)

		let cancelAction = UIAlertAction(
			title: AppStrings.Common.alertActionCancel,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)

		let deleteAction = UIAlertAction(
			title: AppStrings.Common.alertActionRemove,
			style: .destructive,
			handler: { [weak self] _ in
				self?.viewModel.deleteTest()
			}
		)

		alert.addAction(deleteAction)
		alert.addAction(cancelAction)

		present(alert, animated: true, completion: nil)
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
