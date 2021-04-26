//
// 🦠 Corona-Warn-App
//

import UIKit

class DMServerEnvironmentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	// MARK: - Init

	init(
		store: Store,
		downloadedPackagesStore: DownloadedPackagesStore,
		environmentProvider: EnvironmentProviding = Environments()
	) {
		self.store = store
		self.downloadedPackagesStore = downloadedPackagesStore
		self.environmentProvider = environmentProvider
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = ColorCompatibility.systemBackground

		currentEnvironmentLabel = UILabel(frame: .zero)
		currentEnvironmentLabel.translatesAutoresizingMaskIntoConstraints = false
		updateCurrentEnviromentLabel()

		picker = UIPickerView(frame: .zero)
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.dataSource = self
		picker.delegate = self

		let environmentIndex = environmentProvider.environments.firstIndex {
			$0.name == environmentProvider.currentEnvironment().name
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
		return environmentProvider.environments[row].name
	}

	// MARK: - Protocol UIPickerViewDataSource

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return environmentProvider.environments.count
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	// MARK: - Private

	private var store: Store
	private let downloadedPackagesStore: DownloadedPackagesStore
	private let environmentProvider: EnvironmentProviding
	private var currentEnvironmentLabel: UILabel!
	private var picker: UIPickerView!

	private func updateCurrentEnviromentLabel() {
		currentEnvironmentLabel.text = "Selected Environment: \(environmentProvider.currentEnvironment().name)"
	}

	@objc
	private func saveButtonTaped() {
		let quitAlert = UIAlertController(title: "App Restart Needed", message: "To use the new environment you have to restart the app", preferredStyle: .alert)

		let quitAction = UIAlertAction(title: "Save and quit app", style: .destructive) { [weak self] _ in
			guard let self = self else { return }

			let selectedRow = self.picker.selectedRow(inComponent: 0)
			let selectedEnv = self.environmentProvider.environments[selectedRow]

			UserDefaults.standard.setValue(selectedEnv.name, forKey: Environments.selectedEnvironmentKey)
			self.updateCurrentEnviromentLabel()

			self.store.enfRiskCalculationResult = nil
			self.store.checkinRiskCalculationResult = nil
			self.downloadedPackagesStore.reset()
			exit(0)
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		quitAlert.addAction(quitAction)
		quitAlert.addAction(cancelAction)
		present(quitAlert, animated: true)
	}
}
