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

class InfoBoxView: UIView {

	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)

		loadViewFromNib()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)

		loadViewFromNib()
	}
	
	// MARK: - Internal
	
	func update(with viewModel: InfoBoxViewModel) {
		infoBoxTitle.text = viewModel.titleText
		infoBoxText.text = viewModel.descriptionText
		shareButton.setTitle(viewModel.shareText, for: .normal)
		settingsButton.setTitle(viewModel.settingsText, for: .normal)
		
		settingsAction = viewModel.settingsAction
		shareAction = viewModel.shareAction

		instructionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for instruction in viewModel.instructions {
			let titleLabel = ENALabel()
			titleLabel.text = instruction.title
			titleLabel.numberOfLines = 0
			titleLabel.style = .headline

			instructionsStackView.addArrangedSubview(titleLabel)

			for index in 0..<instruction.steps.count {
				let step = instruction.steps[index]

				let containerView = UIView()
				instructionsStackView.addArrangedSubview(containerView)

				let iconImageView = UIImageView(image: step.icon)

				containerView.addSubview(iconImageView)
				iconImageView.translatesAutoresizingMaskIntoConstraints = false

				NSLayoutConstraint.activate([
					iconImageView.widthAnchor.constraint(equalToConstant: 28),
					iconImageView.heightAnchor.constraint(equalToConstant: 28),
					iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
					iconImageView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor)
				])

				let enumerationLabel = ENALabel()
				enumerationLabel.text = "\(index + 1)."
				enumerationLabel.numberOfLines = 1
				enumerationLabel.style = .headline
				enumerationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

				containerView.addSubview(enumerationLabel)
				enumerationLabel.translatesAutoresizingMaskIntoConstraints = false

				NSLayoutConstraint.activate([
					enumerationLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
					enumerationLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor),
					enumerationLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
				])

				let stepLabel = ENALabel()
				stepLabel.text = step.text
				stepLabel.numberOfLines = 0
				stepLabel.style = .headline

				containerView.addSubview(stepLabel)
				stepLabel.translatesAutoresizingMaskIntoConstraints = false

				NSLayoutConstraint.activate([
					stepLabel.leadingAnchor.constraint(equalTo: enumerationLabel.trailingAnchor, constant: 10),
					stepLabel.firstBaselineAnchor.constraint(equalTo: enumerationLabel.firstBaselineAnchor),
					stepLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
					stepLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
				])
			}
		}
	}
	
	// MARK: - Private

	@IBOutlet private weak var infoBoxTitle: ENALabel!
	@IBOutlet private weak var infoBoxText: ENALabel!
	@IBOutlet private weak var instructionsStackView: UIStackView!
	@IBOutlet private weak var settingsButton: UIButton!
	@IBOutlet private weak var shareButton: UIButton!
	
	private var shareAction: () -> Void = { }
	private var settingsAction: () -> Void = { }
	
	private func loadViewFromNib() {
		let nib = UINib(nibName: "InfoBoxView", bundle: nil)
		guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
			return
		}

		addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: topAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor),
			view.bottomAnchor.constraint(equalTo: bottomAnchor),
			view.leadingAnchor.constraint(equalTo: leadingAnchor)
		])
	}
	
	@IBAction private func onShare() {
		shareAction()
	}
	
	@IBAction private func onSettings() {
		settingsAction()
	}

}
