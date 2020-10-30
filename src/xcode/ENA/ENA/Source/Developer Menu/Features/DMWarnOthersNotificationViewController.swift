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

		let stackView = UIStackView(arrangedSubviews: [titleLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 10
		
		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
		])

	}

}
#endif
