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

class ExposureSubmissionHotlineViewController: DynamicTableViewController {
    // MARK: - View lifecycle methods.

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func viewWillAppear(_: Bool) {
        setupButtons()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setSecondaryButtonTitle(to: "")
        hideSecondaryButton()
    }

    // MARK: - View setup.

    private func setUpView() {
        title = AppStrings.ExposureSubmissionHotline.title
        setupButtons()
        setupTableView()
    }

    private func setupButtons() {
        setButtonTitle(to: AppStrings.ExposureSubmissionHotline.callButtonTitle)
        setSecondaryButtonTitle(to: AppStrings.ExposureSubmissionHotline.tanInputButtonTitle)
        showSecondaryButton()
    }

    // MARK: - Data setup.

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DynamicTableViewStepCell.self, forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)

        dynamicTableViewModel = DynamicTableViewModel(
            [.section(
                header: .image(UIImage(named: "Illu_Submission_Kontakt")),
                cells: [
                    .regular(text: AppStrings.ExposureSubmissionHotline.description)
                ]
            ),
             DynamicSection.section(
                cells: [
                    .bigBold(text: AppStrings.ExposureSubmissionHotline.sectionTitle),
                    DynamicCell.identifier(CustomCellReuseIdentifiers.stepCell, action: .none, configure: { _, cell, _ in
                        guard let cell = cell as? DynamicTableViewStepCell else { return }
                        cell.configure(title: AppStrings.ExposureSubmissionHotline.sectionDescription1,
                                       image: .checkmark,
                                       isCircle: true,
                                       iconTintColor: .preferredColor(for: .chevron))
                        }),
                    .identifier(CustomCellReuseIdentifiers.stepCell, action: .none, configure: { _, cell, _ in
                        guard let cell = cell as? DynamicTableViewStepCell else { return }
                        cell.configure(title: AppStrings.ExposureSubmissionHotline.sectionDescription2,
                                       image: .checkmark,
                                       isCircle: true,
                                       iconTintColor: .preferredColor(for: .chevron))
                            })
                ])]
        )
    }
}

// MARK: - Segue identifiers.

extension ExposureSubmissionHotlineViewController {
    enum Segue: String, SegueIdentifiers {
        case tanInput = "tanInputSegue"
    }
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionHotlineViewController {
    enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
        case stepCell
    }
}

// MARK: - ExposureSubmissionNavigationControllerChild Extension.

extension ExposureSubmissionHotlineViewController: ExposureSubmissionNavigationControllerChild {
    func didTapBottomButton() {
        callHotline()
    }

    func didTapSecondButton() {
        performSegue(withIdentifier: Segue.tanInput, sender: self)
    }

    private func callHotline() {
        if let url = URL(string: "telprompt:\(AppStrings.ExposureDetection.hotlineNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
