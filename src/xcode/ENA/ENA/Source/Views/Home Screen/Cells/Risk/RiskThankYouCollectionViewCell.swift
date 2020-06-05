//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

final class RiskThankYouCollectionViewCell: HomeCardCollectionViewCell {

	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var bodyLabel: ENALabel!

	@IBOutlet var noteLabel: ENALabel!

	@IBOutlet var furtherInfoLabel: ENALabel!

	@IBOutlet var viewContainer: UIView!
	@IBOutlet var stackView: UIStackView!

	override func awakeFromNib() {
		super.awakeFromNib()
		constructStackView()
	}

	private func constructStackView() {
		let containerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 32.0, right: 16.0)
		stackView.layoutMargins = containerInsets
		stackView.isLayoutMarginsRelativeArrangement = true
	}

	func removeAllArrangedSubviews() {
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}
	
	func configureTitle(title: String, titleColor: UIColor) {
		titleLabel.text = title
		titleLabel.textColor = titleColor
		stackView.addArrangedSubview(titleLabel)
	}

	func configureImage(imageName: String) {
		let image = UIImage(named: imageName)
		imageView.image = image
		stackView.addArrangedSubview(imageView)
		stackView.setCustomSpacing(16.0, after: imageView)
	}

	func configureBody(text: String, bodyColor: UIColor) {
		bodyLabel.text = text
		bodyLabel.textColor = bodyColor
		stackView.addArrangedSubview(bodyLabel)
		stackView.setCustomSpacing(32.0, after: bodyLabel)
	}

	func configureNoteLabel(title: String) {
		noteLabel.text = title
		stackView.addArrangedSubview(noteLabel)
		stackView.setCustomSpacing(8.0, after: noteLabel)
	}

	func configureFurtherInfoLabel(title: String) {
		furtherInfoLabel.text = title
		stackView.addArrangedSubview(furtherInfoLabel)
		stackView.setCustomSpacing(8.0, after: furtherInfoLabel)
	}

	func configureNoteRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {
		guard let noteIndex = stackView.arrangedSubviews.firstIndex(of: noteLabel) else { return }
		var lastView: UIView?
		for itemConfigurator in cellConfigurators.reversed() {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? RiskItemView {
				stackView.insertArrangedSubview(riskView, at: noteIndex + 1)
				if lastView != nil {
					stackView.setCustomSpacing(0.0, after: riskView)
				} else {
					lastView = riskView
				}
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
		if let last = lastView {
			stackView.setCustomSpacing(22.0, after: last)
		}
	}

	func configureFurtherInfoRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {
		guard let furtherInfoIndex = stackView.arrangedSubviews.firstIndex(of: furtherInfoLabel) else { return }
		var lastView: UIView?
		for itemConfigurator in cellConfigurators.reversed() {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? RiskItemView {
				stackView.insertArrangedSubview(riskView, at: furtherInfoIndex + 1)
				if lastView != nil {
					stackView.setCustomSpacing(0.0, after: riskView)
				} else {
					lastView = riskView
				}
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
	}
}
