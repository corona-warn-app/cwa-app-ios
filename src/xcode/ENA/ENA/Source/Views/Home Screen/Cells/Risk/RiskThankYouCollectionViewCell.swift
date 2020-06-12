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
	@IBOutlet var riskViewStackView: UIStackView!
	@IBOutlet var furtherInfoStackView: UIStackView!

	override func awakeFromNib() {
		super.awakeFromNib()
		stackView.setCustomSpacing(16.0, after: imageView)
		stackView.setCustomSpacing(32.0, after: bodyLabel)
		stackView.setCustomSpacing(8.0, after: noteLabel)
		stackView.setCustomSpacing(22.0, after: riskViewStackView)
		stackView.setCustomSpacing(8.0, after: furtherInfoLabel)
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}

	func configureTitle(title: String, titleColor: UIColor) {
		titleLabel.text = title
		titleLabel.textColor = titleColor
	}

	func configureImage(imageName: String) {
		let image = UIImage(named: imageName)
		imageView.image = image
	}

	func configureBody(text: String, bodyColor: UIColor) {
		bodyLabel.text = text
		bodyLabel.textColor = bodyColor
	}

	func configureNoteLabel(title: String) {
		noteLabel.text = title
	}

	func configureFurtherInfoLabel(title: String) {
		furtherInfoLabel.text = title
	}

	func configureNoteRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {
		riskViewStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		for itemConfigurator in cellConfigurators {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
				riskViewStackView.addArrangedSubview(riskView)
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
		riskViewStackView.isHidden = cellConfigurators.isEmpty

	}

	func configureFurtherInfoRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {
		furtherInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		for itemConfigurator in cellConfigurators {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
				furtherInfoStackView.addArrangedSubview(riskView)
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
		furtherInfoStackView.isHidden = cellConfigurators.isEmpty
	}
}
