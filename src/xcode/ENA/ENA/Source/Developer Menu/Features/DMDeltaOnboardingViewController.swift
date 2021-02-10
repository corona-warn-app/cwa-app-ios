//
// 🦠 Corona-Warn-App
//

import UIKit

class DMDeltaOnboardingViewController: UIViewController, UITextFieldDelegate {

	// MARK: - Attributes

	private let store: Store
	private var textField: UITextField!
	private var currentVersionLabel: UILabel!
	private let tableView = UITableView()
	private var characters = ["Link", "Zelda", "Ganondorf", "Midna"]
	private var safeArea: UILayoutGuide!

	// MARK: - Initializers

	init(store: Store) {
		self.store = store

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Lifecycle Methods

	override func viewDidLoad() {
		super.viewDidLoad()
		safeArea = view.layoutMarginsGuide
		
		view.backgroundColor = ColorCompatibility.systemBackground
		
		currentVersionLabel = UILabel(frame: .zero)
		currentVersionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		updateCurrentVersionLabel()
		
		let button = UIButton(frame: .zero)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Save Onboarding Version", for: .normal)
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		button.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)
		
		let resetButton = UIButton(frame: .zero)
		resetButton.translatesAutoresizingMaskIntoConstraints = false
		resetButton.setTitle("Reset presented delta onboardings", for: .normal)
		resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
		resetButton.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)
		
		textField = UITextField(frame: .zero)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.borderStyle = .bezel
		
		let stackView = UIStackView(arrangedSubviews: [currentVersionLabel, textField, tableView, button, resetButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20
		
		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0)
		])
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
		tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}

	// MARK: - Private API
	
	private func setupTableView() {
		
	}

	private func updateCurrentVersionLabel() {
		currentVersionLabel.text = "Current onboarding version: \(store.onboardingVersion)"
	}
	
	@objc
	private func buttonTapped() {
		store.onboardingVersion = textField.text ?? ""
		updateCurrentVersionLabel()
		let alert = UIAlertController(title: "Saved onboarding version: \(store.onboardingVersion)", message: "", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
		present(alert, animated: true)
	}
	
	@objc
	private func resetButtonTapped() {
		store.finishedDeltaOnboardings = [String: [String]]()
		let alert = UIAlertController(title: "Presented delta onboarding screens have been resetted.", message: "", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
		present(alert, animated: true)
	}
}

extension DMDeltaOnboardingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	return characters.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
	cell.textLabel?.text = characters[indexPath.row]
	return cell
  }
}
