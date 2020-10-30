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
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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
		descriptionLabel.text = "You can use the two input fields below to maintain the time until the notifications will be shown. Time is maintained in seconds."
		descriptionLabel.font = UIFont.enaFont(for: .subheadline)
		
		let setupButton = UIButton(frame: .zero)
		setupButton.translatesAutoresizingMaskIntoConstraints = false
		setupButton.setTitle("Schedule notifications", for: .normal)
		setupButton.addTarget(self, action: #selector(scheduleNotificationsButtonTapped), for: .touchUpInside)
		setupButton.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)
		
		let resetButton = UIButton(frame: .zero)
		resetButton.translatesAutoresizingMaskIntoConstraints = false
		resetButton.setTitle("Cancel notifications", for: .normal)
		resetButton.addTarget(self, action: #selector(resetNotificationsButtonTapped), for: .touchUpInside)
		resetButton.setTitleColor(.enaColor(for: .buttonDestructive), for: .normal)
		
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
		
		let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, time1Label, time1Textfield, time2Label, time2Textfield, setupButton, resetButton])
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
			time1Textfield.widthAnchor.constraint(equalToConstant: 50),
			time2Textfield.widthAnchor.constraint(equalToConstant: 50)
		])
		
	}
	
	// MARK: Private API
	@objc
	private func scheduleNotificationsButtonTapped() {
		print("Schedule button tapped.")
	}
	
	
	@objc
	private func resetNotificationsButtonTapped() {
		print("Reset button tapped.")
	}
	
}
#endif
