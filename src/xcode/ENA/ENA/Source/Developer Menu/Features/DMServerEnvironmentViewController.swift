//
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
//

import UIKit

class DMServerEnvironmentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	// MARK: - Init

	init(
		store: Store,
		downloadedPackagesStore: DownloadedPackagesStore,
		localServerEnvironment: LocalServerEnvironment
	) {
		self.store = store
		self.downloadedPackagesStore = downloadedPackagesStore
		self.localServerEnvironment = localServerEnvironment
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .white

		currentEnvironmentLabel = UILabel(frame: .zero)
		currentEnvironmentLabel.translatesAutoresizingMaskIntoConstraints = false
		updateCurrentEnviromentLabel()

		picker = UIPickerView(frame: .zero)
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.dataSource = self
		picker.delegate = self

		let environmentIndex = localServerEnvironment.availableEnvironments().firstIndex {
			$0.name == store.serverEnvironment.name
		}
		picker.selectRow(environmentIndex ?? 0, inComponent: 0, animated: true)

		let saveButton = UIButton(frame: .zero)
		saveButton.translatesAutoresizingMaskIntoConstraints = false
		saveButton.addTarget(self, action: #selector(saveButtonTaped), for: .touchUpInside)
		saveButton.setTitle("Save", for: .normal)
		saveButton.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)

		let stackView = UIStackView(arrangedSubviews: [currentEnvironmentLabel, picker, saveButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}

	// MARK: - Protocol UIPickerViewDelegate

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return localServerEnvironment.availableEnvironments()[row].name
	}

	// MARK: - Protocol UIPickerViewDataSource

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return localServerEnvironment.availableEnvironments().count
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let store: Store
	private let downloadedPackagesStore: DownloadedPackagesStore
	private let localServerEnvironment: LocalServerEnvironment
	private var currentEnvironmentLabel: UILabel!
	private var picker: UIPickerView!

	private func updateCurrentEnviromentLabel() {
		currentEnvironmentLabel.text = "Selected Environment: \(store.serverEnvironment.name)"
	}

	@objc
	private func saveButtonTaped() {
		let quitAlert = UIAlertController(title: "App Restart Needed", message: "To use the new environment you have to restart the app", preferredStyle: .alert)

		let quitAction = UIAlertAction(title: "Save and quit app", style: .destructive) { [weak self] _ in
			guard let self = self else { return }

			let selectedRow = self.picker.selectedRow(inComponent: 0)
			self.store.serverEnvironment = self.localServerEnvironment.availableEnvironments()[selectedRow]
			self.updateCurrentEnviromentLabel()
			self.store.summary = nil
			self.downloadedPackagesStore.reset()
			exit(0)
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		quitAlert.addAction(quitAction)
		quitAlert.addAction(cancelAction)
		present(quitAlert, animated: true)
	}
}
