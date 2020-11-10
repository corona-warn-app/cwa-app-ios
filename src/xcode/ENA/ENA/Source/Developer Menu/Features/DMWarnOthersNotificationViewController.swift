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

#if !RELEASE

import UIKit

final class DMWarnOthersNotificationViewController: UIViewController, UITextFieldDelegate {
	
	
	// MARK: Properties
	private var time1Textfield: UITextField!
	private var time2Textfield: UITextField!
	
	private var time1Label: UILabel!
	private var time2Label: UILabel!
	
	private let store: Store
	private var warnOthers: WarnOthersRemindable
	
	
	// MARK: - Init
	
	init(warnOthers: WarnOthersRemindable, store: Store) {
		self.store = store
		self.warnOthers = warnOthers
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		
		let titleLabel = UILabel(frame: .zero)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.numberOfLines = 0
		titleLabel.text = "Warn others notification settings"
		titleLabel.font = UIFont.enaFont(for: .headline)
		
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
		
		let descriptionLabelResetNotifications = UILabel(frame: .zero)
		descriptionLabelResetNotifications.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabelResetNotifications.numberOfLines = 0
		descriptionLabelResetNotifications.text = "If you want to let the notifications get scheduled again (eg. for testing purposes), just press the reset button below and after that you navigate back to the corresponding views of the app, the notifications will get scheduled again.\nYou can also check 'DM Pending Notifications', to check which ones are scheduled."
		descriptionLabelResetNotifications.font = UIFont.enaFont(for: .subheadline)
		
		let resetNotificationsButton = UIButton(frame: .zero)
		resetNotificationsButton.translatesAutoresizingMaskIntoConstraints = false
		resetNotificationsButton.setTitle("Reset notification state", for: .normal)
		resetNotificationsButton.addTarget(self, action: #selector(resetNotificationsButtonTapped), for: .touchUpInside)
		resetNotificationsButton.setTitleColor(.enaColor(for: .buttonDestructive), for: .normal)
		
		time1Label = UILabel(frame: .zero)
		time1Label.translatesAutoresizingMaskIntoConstraints = false
		time1Label.numberOfLines = 0
		time1Label.text = "Notification 1 time (sec)"
		
		time2Label = UILabel(frame: .zero)
		time2Label.translatesAutoresizingMaskIntoConstraints = false
		time2Label.numberOfLines = 0
		time2Label.text = "Notification 2 time (sec)"
		
		time1Textfield = UITextField(frame: .zero)
		time1Textfield.translatesAutoresizingMaskIntoConstraints = false
		time1Textfield.delegate = self
		time1Textfield.borderStyle = .line
		
		time2Textfield = UITextField(frame: .zero)
		time2Textfield.translatesAutoresizingMaskIntoConstraints = false
		time2Textfield.delegate = self
		time2Textfield.borderStyle = .line
	
		
		let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, time1Label, time1Textfield, time2Label, time2Textfield, saveButton, resetDefaultsButton, descriptionLabelResetNotifications, resetNotificationsButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 10
		stackView.setCustomSpacing(20, after: descriptionLabel)
		
		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			time1Textfield.widthAnchor.constraint(equalToConstant: 70),
			time2Textfield.widthAnchor.constraint(equalToConstant: 70)
		])
		
		// Set Default Value for the notification text filelds:
		time1Textfield.text = "\(warnOthers.notificationOneTimer)"
		time2Textfield.text = "\(warnOthers.notificationTwoTimer)"
		
		//Set the keyboard type.
		time1Textfield.keyboardType = .numberPad
		time2Textfield.keyboardType = .numberPad
		self.hideKeyboardWhenTappedAround()
		
	}
	
	// MARK: - Private API
	@objc
	private func scheduleNotificationsButtonTapped() {
		let time1 = Double(time1Textfield.text ?? "")
		let time2 = Double(time2Textfield.text ?? "")
		
		// Create an alert when user enter the wrong values.
		if time2 ?? WarnOthersNotificationsTimer.timerOneTime.rawValue <= time1 ?? WarnOthersNotificationsTimer.timerTwoTime.rawValue {
			
			// Display second notification should be greater than first notification alert.
			alertMessage(titleStr: "Please Enter the Correct Notification Time", messageStr: "Second notification time seconds should be greater than the first notification time seconds.")

		} else {
			// Save the notifications time into the SecureStore.
			warnOthers.notificationOneTimer = TimeInterval(time1 ?? WarnOthersNotificationsTimer.timerOneTime.rawValue)
			warnOthers.notificationTwoTimer = TimeInterval(time2 ?? WarnOthersNotificationsTimer.timerTwoTime.rawValue)
			
			//Display notification save alert.
			alertMessage(titleStr: "Notifications time saved", messageStr: "Notification1 time \(time1 ?? WarnOthersNotificationsTimer.timerOneTime.rawValue) seconds & Notification2 time \(time2 ?? WarnOthersNotificationsTimer.timerTwoTime.rawValue) seconds has saved into the secure store.")
		}

	}
	
	
	@objc
	private func resetDefaultsButtonTapped() {
		time1Textfield.text = "\(WarnOthersNotificationsTimer.timerOneTime.rawValue)"
		time2Textfield.text = "\(WarnOthersNotificationsTimer.timerTwoTime.rawValue)"
	}
	
	@objc
	private func resetNotificationsButtonTapped() {
		warnOthers.reset()
		alertMessage(titleStr: "Done", messageStr: "Warn others notifications can appear again.")

	}
}

// MARK: - Set the alert popups.
extension DMWarnOthersNotificationViewController {
	func alertMessage(titleStr: String, messageStr: String) {
		// create the alert
		let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert)
		// add an action button
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
		// show the alert
		self.present(alert, animated: true, completion: nil)
	}
}

// MARK: - Dismiss the keyboard
extension DMWarnOthersNotificationViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DMWarnOthersNotificationViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	@objc
	func dismissKeyboard() {
		view.endEditing(true)
	}
}
#endif
