//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit
import OpenCombine

final class DMWarnOthersNotificationViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: - Init
	
	init(
		warnOthersReminder: WarnOthersReminder,
		store: Store,
		coronaTestService: CoronaTestServiceProviding
	) {
		self.store = store
		self.warnOthersReminder = warnOthersReminder
		self.coronaTestService = coronaTestService
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	// swiftlint:disable:next function_body_length
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = ColorCompatibility.systemBackground
		
		let titleLabel = UILabel(frame: .zero)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.numberOfLines = 0
		titleLabel.text = "\n\nWarn others notification settings"
		titleLabel.font = UIFont.enaFont(for: .headline)
		
		let currentSubmissionConsentStatusTitleLabel = UILabel(frame: .zero)
		currentSubmissionConsentStatusTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		currentSubmissionConsentStatusTitleLabel.numberOfLines = 0
		currentSubmissionConsentStatusTitleLabel.text = "Current status of submission consent\n"
		currentSubmissionConsentStatusTitleLabel.font = UIFont.enaFont(for: .headline)
		
		currentPCRSubmissionConsentStatusStateLabel = UILabel(frame: .zero)
		currentPCRSubmissionConsentStatusStateLabel.translatesAutoresizingMaskIntoConstraints = false
		currentPCRSubmissionConsentStatusStateLabel.numberOfLines = 0
		currentPCRSubmissionConsentStatusStateLabel.font = UIFont.enaFont(for: .title2)

		currentAntigenSubmissionConsentStatusStateLabel = UILabel(frame: .zero)
		currentAntigenSubmissionConsentStatusStateLabel.translatesAutoresizingMaskIntoConstraints = false
		currentAntigenSubmissionConsentStatusStateLabel.numberOfLines = 0
		currentAntigenSubmissionConsentStatusStateLabel.font = UIFont.enaFont(for: .title2)
		
		let currentSubmissionConsentStatusStateDescription = UILabel(frame: .zero)
		currentSubmissionConsentStatusStateDescription.translatesAutoresizingMaskIntoConstraints = false
		currentSubmissionConsentStatusStateDescription.numberOfLines = 0
		currentSubmissionConsentStatusStateDescription.text = "\n⚠️ If SubmissionConsent is granted (🟢), then no warn others notifications will be scheduled!"
		currentSubmissionConsentStatusStateDescription.font = UIFont.enaFont(for: .subheadline)

		let descriptionLabel = UILabel(frame: .zero)
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = "You can use the two input fields below to maintain the time until the notifications will be shown.\nTime is maintained in seconds."
		descriptionLabel.font = UIFont.enaFont(for: .subheadline)
		
		let saveButton = UIButton(frame: .zero)
		saveButton.translatesAutoresizingMaskIntoConstraints = false
		saveButton.setTitle("Save timer values", for: .normal)
		saveButton.addTarget(self, action: #selector(scheduleNotificationsButtonTapped), for: .touchUpInside)
		saveButton.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)
		
		let resetDefaultsButton = UIButton(frame: .zero)
		resetDefaultsButton.translatesAutoresizingMaskIntoConstraints = false
		resetDefaultsButton.setTitle("Reset values to default", for: .normal)
		resetDefaultsButton.addTarget(self, action: #selector(resetDefaultsButtonTapped), for: .touchUpInside)
		resetDefaultsButton.setTitleColor(.enaColor(for: .buttonDestructive), for: .normal)
		
		let descriptionResetNotificationsLabel = UILabel(frame: .zero)
		descriptionResetNotificationsLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionResetNotificationsLabel.numberOfLines = 0
		descriptionResetNotificationsLabel.text = "If you want to let the notifications get scheduled again (eg. for testing purposes), just press the reset button below and after that you navigate back to the corresponding views of the app, the notifications will get scheduled again.\nYou can also check 'DM Pending Notifications', to check which ones are scheduled."
		descriptionResetNotificationsLabel.font = UIFont.enaFont(for: .subheadline)
		
		let resetNotificationsButton = UIButton(frame: .zero)
		resetNotificationsButton.translatesAutoresizingMaskIntoConstraints = false
		resetNotificationsButton.setTitle("Reset notification state", for: .normal)
		resetNotificationsButton.addTarget(self, action: #selector(resetNotificationsButtonTapped), for: .touchUpInside)
		resetNotificationsButton.setTitleColor(.enaColor(for: .buttonDestructive), for: .normal)
		
		timeInterval1Label = UILabel(frame: .zero)
		timeInterval1Label.translatesAutoresizingMaskIntoConstraints = false
		timeInterval1Label.numberOfLines = 0
		timeInterval1Label.text = "Notification 1 time (sec)"
		
		timeInterval2Label = UILabel(frame: .zero)
		timeInterval2Label.translatesAutoresizingMaskIntoConstraints = false
		timeInterval2Label.numberOfLines = 0
		timeInterval2Label.text = "Notification 2 time (sec)"
		
		timeInterval1TextField = UITextField(frame: .zero)
		timeInterval1TextField.translatesAutoresizingMaskIntoConstraints = false
		timeInterval1TextField.delegate = self
		timeInterval1TextField.borderStyle = .line
		
		timeInterval2TextField = UITextField(frame: .zero)
		timeInterval2TextField.translatesAutoresizingMaskIntoConstraints = false
		timeInterval2TextField.delegate = self
		timeInterval2TextField.borderStyle = .line
		
		pcrConsentSwitch.onTintColor = .enaColor(for: .tint)
		pcrConsentSwitch.addTarget(self, action: #selector(self.pcrConsentStateChanged), for: .valueChanged)

		antigenConsentSwitch.onTintColor = .enaColor(for: .tint)
		antigenConsentSwitch.addTarget(self, action: #selector(self.pcrConsentStateChanged), for: .valueChanged)
		
		let stackView = UIStackView(arrangedSubviews: [currentSubmissionConsentStatusTitleLabel, currentPCRSubmissionConsentStatusStateLabel, pcrConsentSwitch, currentAntigenSubmissionConsentStatusStateLabel, antigenConsentSwitch, currentSubmissionConsentStatusStateDescription, titleLabel, descriptionLabel, timeInterval1Label, timeInterval1TextField, timeInterval2Label, timeInterval2TextField, saveButton, resetDefaultsButton, descriptionResetNotificationsLabel, resetNotificationsButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 10
		stackView.setCustomSpacing(20, after: descriptionLabel)

		view.addSubview(scrollview)
		scrollview.addSubview(stackView)
		scrollview.translatesAutoresizingMaskIntoConstraints = false
		stackView.translatesAutoresizingMaskIntoConstraints = false

		let heightAnchor = stackView.heightAnchor.constraint(equalTo: scrollview.heightAnchor)
		heightAnchor.priority = .defaultLow

		NSLayoutConstraint.activate([
			scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollview.topAnchor.constraint(equalTo: view.topAnchor),
			scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: 10),
			stackView.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor, constant: -10),
			stackView.topAnchor.constraint(equalTo: scrollview.topAnchor, constant: 10),
			stackView.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
			stackView.widthAnchor.constraint(equalTo: scrollview.widthAnchor, constant: -20),
			heightAnchor,
			timeInterval1TextField.widthAnchor.constraint(equalToConstant: 70),
			timeInterval2TextField.widthAnchor.constraint(equalToConstant: 70)
		])
		
		// Set Default Value for the notification text fields:
		timeInterval1TextField.text = "\(warnOthersReminder.notificationOneTimeInterval)"
		timeInterval2TextField.text = "\(warnOthersReminder.notificationTwoTimeInterval)"
		
		// Set the keyboard type.
		timeInterval1TextField.keyboardType = .numberPad
		timeInterval2TextField.keyboardType = .numberPad
		self.hideKeyboardWhenTappedAround()

		setupSubscriptions()
	}
	
	// MARK: - Private

	private let scrollview = UIScrollView()

	private let pcrConsentSwitch = UISwitch()
	private let antigenConsentSwitch = UISwitch()
	
	private var subscriptions: Set<AnyCancellable> = []
	
	private var coronaTestService: CoronaTestServiceProviding
	
	private var timeInterval1TextField: UITextField!
	private var timeInterval2TextField: UITextField!

	private var timeInterval1Label: UILabel!
	private var timeInterval2Label: UILabel!

	private let store: Store
	private var warnOthersReminder: WarnOthersReminder
	
	private var currentPCRSubmissionConsentStatusStateLabel = UILabel()
	private var currentAntigenSubmissionConsentStatusStateLabel = UILabel()

	private func setupSubscriptions() {
		coronaTestService.pcrTest
			.sink { pcrTest in
				self.pcrConsentSwitch.isEnabled = pcrTest != nil

				guard let pcrTest = pcrTest else {
					self.currentPCRSubmissionConsentStatusStateLabel.text = "No PCR test registered"
					return
				}

				self.pcrConsentSwitch.isOn = pcrTest.isSubmissionConsentGiven
				self.currentPCRSubmissionConsentStatusStateLabel.text = pcrTest.isSubmissionConsentGiven ? "PCR: 🟢 Consent granted 👍" : "PCR: 🔴 Consent not given 👎"
			}
			.store(in: &subscriptions)

		coronaTestService.antigenTest
			.sink { antigenTest in
				self.antigenConsentSwitch.isEnabled = antigenTest != nil

				guard let antigenTest = antigenTest else {
					self.currentAntigenSubmissionConsentStatusStateLabel.text = "No Antigen test registered"
					return
				}

				self.antigenConsentSwitch.isOn = antigenTest.isSubmissionConsentGiven
				self.currentAntigenSubmissionConsentStatusStateLabel.text = antigenTest.isSubmissionConsentGiven ? "Antigen: 🟢 Consent granted 👍" : "Antigen: 🔴 Consent not given 👎"
			}
			.store(in: &subscriptions)
	}
	
	@objc
	private func pcrConsentStateChanged(switchState: UISwitch) {
		coronaTestService.pcrTest.value?.isSubmissionConsentGiven = switchState.isOn
	}

	@objc
	private func antigenConsentStateChanged(switchState: UISwitch) {
		coronaTestService.antigenTest.value?.isSubmissionConsentGiven = switchState.isOn
	}
	
	@objc
	private func scheduleNotificationsButtonTapped() {
		let timeInterval1 = Double(timeInterval1TextField.text ?? "") ?? WarnOthersNotificationsTimeInterval.intervalOne
		let timeInterval2 = Double(timeInterval2TextField.text ?? "") ?? WarnOthersNotificationsTimeInterval.intervalTwo
		
		// Create an alert when user enter the wrong values.
		if timeInterval2 <= timeInterval1 {
			// Display second notification should be greater than first notification alert.
			showAlert(title: "Please Enter the Correct Notification Time", message: "Second notification time seconds should be greater than the first notification time seconds.")
		} else {
			// Save the notifications time into the SecureStore.
			warnOthersReminder.notificationOneTimeInterval = TimeInterval(timeInterval1)
			warnOthersReminder.notificationTwoTimeInterval = TimeInterval(timeInterval2)
			
			// Display notification save alert.
			showAlert(title: "Notifications time saved", message: "Notification1 time \(timeInterval1) seconds & Notification2 time \(timeInterval2) seconds has saved into the secure store.")
		}
	}

	@objc
	private func resetDefaultsButtonTapped() {
		timeInterval1TextField.text = "\(WarnOthersNotificationsTimeInterval.intervalOne)"
		timeInterval2TextField.text = "\(WarnOthersNotificationsTimeInterval.intervalTwo)"
	}
	
	@objc
	private func resetNotificationsButtonTapped() {
		warnOthersReminder.reset()
		showAlert(title: "Done", message: "Warn others notifications can appear again.")
	}

	private func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}

	private func hideKeyboardWhenTappedAround() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}

	@objc
	private func dismissKeyboard() {
		view.endEditing(true)
	}

}

#endif
