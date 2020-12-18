//
// 🦠 Corona-Warn-App
//

import UIKit

class DynamicTableViewConsentCell: UITableViewCell {
	
	// MARK: - View elements.
	lazy var subTitleLabel = ENALabel(frame: .zero)
	lazy var descriptionPart1Label = ENALabel(frame: .zero)
	lazy var descriptionPart2Label = ENALabel(frame: .zero)
	lazy var seperatorView1 = UIView()
	lazy var seperatorView2 = UIView()
	lazy var flagIconsLabel = ENALabel(frame: .zero)
	lazy var flagCountriesLabel = ENALabel(frame: .zero)
	lazy var descriptionPart3Label = ENALabel(frame: .zero)
	lazy var descriptionPart4Label = ENALabel(frame: .zero)
	lazy var consentView = UIView(frame: .zero)
	lazy var consentStackView = UIStackView(frame: .zero)
	lazy var countriesStackView = UIStackView(frame: .zero)
	
	
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
		isAccessibilityElement = false
		
		// MARK: - General cell setup.
		selectionStyle = .none
		backgroundColor = .clear
		
		// MARK: - Add consent view
		consentView.backgroundColor = .enaColor(for: .separator)
		consentView.layer.cornerRadius = 16.0
		contentView.addSubview(consentView)
		
		// MARK: - Stackview adjustment.
		consentStackView.axis = .vertical
		consentStackView.spacing = 20
		consentStackView.distribution = .fill
		consentView.addSubview(consentStackView)
		
		UIView.translatesAutoresizingMaskIntoConstraints(for: [
			consentView, consentStackView
		], to: false)

		// MARK: - Title adjustment.
		subTitleLabel.style = .headline
		subTitleLabel.textColor = .enaColor(for: .textPrimary1)
		subTitleLabel.lineBreakMode = .byWordWrapping
		subTitleLabel.numberOfLines = 0
		
		// MARK: - Description1 Body adjustment.
		descriptionPart1Label.style = .headline
		descriptionPart1Label.textColor = .enaColor(for: .textPrimary1)
		descriptionPart1Label.lineBreakMode = .byWordWrapping
		descriptionPart1Label.numberOfLines = 0
		
		// MARK: - Description2 Body adjustment.
		descriptionPart2Label.style = .headline
		descriptionPart2Label.textColor = .enaColor(for: .textPrimary1)
		descriptionPart2Label.lineBreakMode = .byWordWrapping
		descriptionPart2Label.numberOfLines = 0
		
		// MARK: - Description3 Body adjustment.
		descriptionPart3Label.style = .headline
		descriptionPart3Label.textColor = .enaColor(for: .textPrimary1)
		descriptionPart3Label.lineBreakMode = .byWordWrapping
		descriptionPart3Label.numberOfLines = 0
		
		// MARK: - Description4 Body adjustment.
		descriptionPart4Label.style = .body
		descriptionPart4Label.textColor = .enaColor(for: .textPrimary1)
		descriptionPart4Label.lineBreakMode = .byWordWrapping
		descriptionPart4Label.numberOfLines = 0
		
		// MARK: - Countries StackView Body adjustment.
		countriesStackView.axis = .vertical
		countriesStackView.spacing = 8
		countriesStackView.isLayoutMarginsRelativeArrangement = true
		countriesStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
		
		// MARK: - Flag Icons Label adjustment.
		flagIconsLabel.lineBreakMode = .byWordWrapping
		flagIconsLabel.numberOfLines = 0
		countriesStackView.addArrangedSubview(flagIconsLabel)
		
		// MARK: - Flag Countries Label adjustment.
		flagCountriesLabel.style = .body
		flagCountriesLabel.textColor = .enaColor(for: .textPrimary1)
		flagCountriesLabel.lineBreakMode = .byWordWrapping
		flagCountriesLabel.numberOfLines = 0
		countriesStackView.addArrangedSubview(flagCountriesLabel)
		
		// MARK: - Seperator View1 adjustment.
		seperatorView1.backgroundColor = .enaColor(for: .hairline)
		
		// MARK: - Seperator View2 Body adjustment.
		seperatorView2.backgroundColor = .enaColor(for: .hairline)
		
		[subTitleLabel, descriptionPart1Label, descriptionPart2Label, seperatorView1, countriesStackView, seperatorView2, descriptionPart3Label, descriptionPart4Label].forEach {
			consentStackView.addArrangedSubview($0)
		}
		consentStackView.setCustomSpacing(16, after: seperatorView1)
		consentStackView.setCustomSpacing(16, after: flagCountriesLabel)
		consentStackView.setNeedsUpdateConstraints()
		accessibilityElements = [subTitleLabel, descriptionPart1Label, descriptionPart2Label, flagCountriesLabel, descriptionPart3Label, descriptionPart4Label]
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
			consentStackView.bottomAnchor.constraint(equalTo: consentView.bottomAnchor, constant: -20),
			seperatorView1.heightAnchor.constraint(equalToConstant: 1),
			seperatorView2.heightAnchor.constraint(equalToConstant: 1)

		])
		
	}
	
	func configure(
		subTitleLabel: NSMutableAttributedString,
		descriptionPart1Label: NSMutableAttributedString,
		descriptionPart2Label: NSMutableAttributedString,
		countries: [Country],
		descriptionPart3Label: NSMutableAttributedString,
		descriptionPart4Label: NSMutableAttributedString
	) {
		self.subTitleLabel.attributedText = subTitleLabel
		self.descriptionPart1Label.attributedText = descriptionPart1Label
		self.descriptionPart2Label.attributedText = descriptionPart2Label
		self.descriptionPart3Label.attributedText = descriptionPart3Label
		self.descriptionPart4Label.attributedText = descriptionPart4Label
		self.flagCountriesLabel.text = countries.map { $0.localizedName }.joined(separator: ", ")
		
		let flagString = NSMutableAttributedString()
		
		countries
			.compactMap { $0.flag?.withRenderingMode(.alwaysOriginal) }
			.forEach { flag in
				let imageAttachment = NSTextAttachment()
				imageAttachment.image = flag
				imageAttachment.setImageHeight(height: 17)
				let imageString = NSAttributedString(attachment: imageAttachment)
				flagString.append(imageString)
				flagString.append(NSAttributedString(string: "   "))
			}

		let style = NSMutableParagraphStyle()
		style.lineSpacing = 10
		flagString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: flagString.length))
				
		flagIconsLabel.attributedText = flagString
	}
}
