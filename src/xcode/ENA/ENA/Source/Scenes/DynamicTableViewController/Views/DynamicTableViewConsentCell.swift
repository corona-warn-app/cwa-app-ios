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

import UIKit

class DynamicTableViewConsentCell: UITableViewCell {
	
	// MARK: - View elements.
	//ToDo: Remove consent from the naming like: subTitleLabel
	lazy var subTitleLabel = ENALabel(frame: .zero)
	lazy var descriptionPart1Label = ENALabel(frame: .zero)
	lazy var descriptionPart2Label = ENALabel(frame: .zero)
	lazy var seperatorView1 = UIView(frame: .zero)
	lazy var seperatorView2 = UIView(frame: .zero)
	lazy var flagIconsLabel = ENALabel(frame: .zero)
	lazy var flagCountriesLabel = ENALabel(frame: .zero)
	lazy var descriptionPart3Label = ENALabel(frame: .zero)
	lazy var descriptionPart4Label = ENALabel(frame: .zero)
	lazy var consentView = UIView(frame: .zero)
	lazy var consentStackView = UIStackView(frame: .zero)
	
	
	// MARK: - Init
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setup()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		
		// MARK: - General cell setup.
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)
		
		// MARK: - Add consent view
		consentView.backgroundColor = .enaColor(for: .separator)
		consentView.layer.cornerRadius = 16.0
		consentView.setContentCompressionResistancePriority(.required, for: .vertical)

		// MARK: - consentTitle adjustment.
		subTitleLabel.style = .headline
		subTitleLabel.textColor = .enaColor(for: .textPrimary1)
		subTitleLabel.lineBreakMode = .byWordWrapping
		subTitleLabel.numberOfLines = 0
		
		// MARK: - Body adjustment.
		descriptionPart1Label.style = .body
		descriptionPart1Label.textColor = .enaColor(for: .textPrimary1)
		descriptionPart1Label.lineBreakMode = .byWordWrapping
		descriptionPart1Label.numberOfLines = 0
		descriptionPart1Label.setContentCompressionResistancePriority(.required, for: .vertical)
		
		// MARK: - Body2 adjustment.
		descriptionPart2Label.style = .body
		descriptionPart2Label.textColor = .enaColor(for: .textPrimary1)
		descriptionPart2Label.lineBreakMode = .byWordWrapping
		descriptionPart2Label.numberOfLines = 0
		
		// MARK: - Body3 adjustment.
		descriptionPart3Label.style = .body
		descriptionPart3Label.textColor = .enaColor(for: .textPrimary1)
		descriptionPart3Label.lineBreakMode = .byWordWrapping
		descriptionPart3Label.numberOfLines = 0
		
		// MARK: - Body4 adjustment.
		descriptionPart4Label.style = .body
		descriptionPart4Label.textColor = .enaColor(for: .textPrimary1)
		descriptionPart4Label.lineBreakMode = .byWordWrapping
		descriptionPart4Label.numberOfLines = 0
		
		// MARK: - Stackview adjustment.
			consentStackView = UIStackView(frame: .zero)
			consentStackView.axis = .vertical
			consentStackView.spacing = 8
			consentStackView.distribution = .fillProportionally
		contentView.addSubview(consentView)
		consentView.addSubview(consentStackView)
		
		
		UIView.translatesAutoresizingMaskIntoConstraints(for: [
			consentView, consentStackView
		], to: false)
		
		[subTitleLabel, descriptionPart1Label, descriptionPart2Label, seperatorView1, flagIconsLabel, flagCountriesLabel, descriptionPart3Label, descriptionPart4Label].forEach {
			consentStackView.addArrangedSubview($0)
		}
	}
	
	
	private func setupConstraints() {
		let marginGuide = contentView.layoutMarginsGuide
		

		NSLayoutConstraint.activate([
			consentView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor),
			consentView.topAnchor.constraint(equalTo: marginGuide.topAnchor),
			consentView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor),
			consentView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor),
			consentStackView.topAnchor.constraint(equalTo: consentView.topAnchor, constant: 20),
			consentStackView.trailingAnchor.constraint(equalTo: consentView.trailingAnchor, constant: -16),
			consentStackView.leadingAnchor.constraint(equalTo: consentView.leadingAnchor, constant: 16),
			consentStackView.bottomAnchor.constraint(equalTo: consentView.bottomAnchor, constant: -20)

		])
		consentStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
		consentStackView.setContentCompressionResistancePriority(.required, for: .vertical)
	}
	
	func configure(
		subTitleLabel: NSMutableAttributedString,
		descriptionPart1Label: NSMutableAttributedString,
		descriptionPart2Label: NSMutableAttributedString,
		flagIconsLabel: NSMutableAttributedString,
		flagCountriesLabel: NSMutableAttributedString,
		descriptionPart3Label: NSMutableAttributedString,
		descriptionPart4Label: NSMutableAttributedString
	) {
		self.subTitleLabel.attributedText = subTitleLabel
		self.descriptionPart1Label.attributedText = descriptionPart1Label
		self.descriptionPart2Label.attributedText = descriptionPart2Label
		self.descriptionPart3Label.attributedText = descriptionPart3Label
		self.descriptionPart4Label.attributedText = descriptionPart4Label
		self.flagIconsLabel.attributedText = flagIconsLabel
		self.flagCountriesLabel.attributedText = flagCountriesLabel
	}
	
}
