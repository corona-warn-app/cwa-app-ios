//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMSQLiteErrorViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: Properties

	private let store: Store
	private var textField: UITextField!
	private var currentErrorCodeLabel: UILabel!

	init(store: Store) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = ColorCompatibility.systemBackground

		let titleLabel = UILabel(frame: .zero)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.numberOfLines = 0
		titleLabel.text = "Simulate SQLite Error"
		titleLabel.font = UIFont.enaFont(for: .headline)

		let errorDescriptionsTitleLabel = UILabel(frame: .zero)
		errorDescriptionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		errorDescriptionsTitleLabel.numberOfLines = 0
		errorDescriptionsTitleLabel.text = "The following errors are handled by the app. Enter the error code and save it to test the error handling."
		errorDescriptionsTitleLabel.font = UIFont.enaFont(for: .subheadline)

		// SQLite error codes can be found here: https://sqlite.org/rescode.html
		let handledErrorCodeDescriptions = [
			"13: \"The SQLITE_FULL result code indicates that a write could not complete because the disk is full.\""		]

		var errorDescriptionLabels = [UILabel]()

		for errorDescription in handledErrorCodeDescriptions {
			let errorDescriptionLabel = UILabel(frame: .zero)
			errorDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
			errorDescriptionLabel.numberOfLines = 0
			errorDescriptionLabel.text = errorDescription
			errorDescriptionLabel.textColor = .enaColor(for: .textPrimary2)
			errorDescriptionLabel.font = UIFont.enaFont(for: .footnote)
			errorDescriptionLabels.append(errorDescriptionLabel)
		}

		currentErrorCodeLabel = UILabel(frame: .zero)
		currentErrorCodeLabel.translatesAutoresizingMaskIntoConstraints = false
		updateCurrentErrorCodeLabel()

		let setupButton = UIButton(frame: .zero)
		setupButton.translatesAutoresizingMaskIntoConstraints = false
		setupButton.setTitle("Save SQLite Error Code", for: .normal)
		setupButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		setupButton.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)

		let resetButton = UIButton(frame: .zero)
		resetButton.translatesAutoresizingMaskIntoConstraints = false
		resetButton.setTitle("Reset SQLite Error Code", for: .normal)
		resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
		resetButton.setTitleColor(.enaColor(for: .buttonDestructive), for: .normal)

		textField = UITextField(frame: .zero)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.borderStyle = .bezel

		let stackView = UIStackView(arrangedSubviews: [titleLabel, errorDescriptionsTitleLabel] + errorDescriptionLabels + [currentErrorCodeLabel, textField, setupButton, resetButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 10
		stackView.setCustomSpacing(20, after: errorDescriptionsTitleLabel)

		if let lasterrorDescriptionLabel = errorDescriptionLabels.last {
			stackView.setCustomSpacing(40, after: lasterrorDescriptionLabel)
		}

		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			textField.widthAnchor.constraint(equalToConstant: 50)
		])

	}

	// MARK: - Private API

	private func updateCurrentErrorCodeLabel() {
		if let errorCode = store.fakeSQLiteError {
			currentErrorCodeLabel.text = "Current configured error code: \(errorCode)"
		} else {
			currentErrorCodeLabel.text = "No error code configured."
		}
	}

	@objc
	private func buttonTapped() {
		guard let errorCode = Int32(textField.text ?? "") else {
			resetErrorCode()
			return
		}

		store.fakeSQLiteError = errorCode
		updateCurrentErrorCodeLabel()

		let alert = UIAlertController(title: "Setup done", message: "Setup done for error code: \(errorCode)", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
		present(alert, animated: true)
	}

	@objc
	private func resetButtonTapped() {
		resetErrorCode()
	}

	private func resetErrorCode() {
		store.fakeSQLiteError = nil
		updateCurrentErrorCodeLabel()
		textField.text = ""
		showResetDoneAlert()
	}

	private func showResetDoneAlert() {
		let alert = UIAlertController(title: "Reset done", message: "You have reset the error code. No error code will be used.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
		present(alert, animated: true)
		return
	}

}
#endif
