////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class DynamicLegalExtendedCell: UITableViewCell, ReuseIdentifierProviding {

	@IBOutlet private var cardView: UIView!
	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var descriptionLabel1: ENALabel!
	@IBOutlet private var descriptionLabel2: ENALabel!

	@IBOutlet private var containerStackView: UIStackView!
	@IBOutlet private var contentStackView1: UIStackView!
	@IBOutlet private var contentStackView2: UIStackView!

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		guard cardView != nil else { return }
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	/// Configure a legal extended cell:
	/// - Parameters:
	/// - title, (bold)
	/// - subheadline1 (bold)
	/// - bulletPoints1
	/// - subheadline2 (bold)
	/// - bulletPoints2
	func configure(title: NSAttributedString, subheadline1: NSAttributedString?, bulletPoints1: [NSAttributedString]?, subheadline2: NSAttributedString?, bulletPoints2: [NSAttributedString]?, accessibilityIdentifier: String? = nil) {
		
		let label = ENALabel() // get the default font – create fake label

		let textBlocks1 = bulletPoints1?.map({ $0.bulletPointString(bulletPointFont: label.font) }) ?? []
		let textBlocks2 = bulletPoints2?.map({ $0.bulletPointString(bulletPointFont: label.font) }) ?? []

		configure(title: title, description1: subheadline1, description2: subheadline2, textBlocks1: textBlocks1, textBlocks2: textBlocks2, accessibilityIdentifier: accessibilityIdentifier)
	}
	
	/// Configure a legal extended cell:
	/// - Parameters:
	/// - title, (bold)
	/// - subheadline1 (bold)
	/// - bulletPoints1
	/// - subheadline2 (bold)
	/// - bulletPoints2
	func configure(title: NSAttributedString, subheadline1: NSAttributedString?, bulletPoints: [NSAttributedString]?, subheadline2: NSAttributedString?, accessibilityIdentifier: String? = nil, spacing: CGFloat) {
		
		containerStackView.spacing = 10

		let label = ENALabel() // get the default font – create fake label
		let textBlocks1 = bulletPoints?.map({ $0.bulletPointString(bulletPointFont: label.font) }) ?? []

		configure(title: title, description1: subheadline1, description2: subheadline2, textBlocks1: textBlocks1, textBlocks2: [], accessibilityIdentifier: accessibilityIdentifier)
	}
	
	/// Configure a legal extended cell:
	/// - Parameters:
	/// - title, (bold)
	/// - description (bold)
	/// - bulletPoints
	func configure(title: NSAttributedString, description: NSAttributedString?, bulletPoints: [NSAttributedString]?, accessibilityIdentifier: String? = nil) {
		
		let label = ENALabel() // get the default font – create fake label
		
		let textBlocks1 = bulletPoints?.map({ $0.bulletPointString(bulletPointFont: label.font) }) ?? []
		let textBlocks2 = [NSAttributedString]()
		
		let description2 = NSAttributedString(string: "")
		configure(title: title, description1: description, description2: description2, textBlocks1: textBlocks1, textBlocks2: textBlocks2, accessibilityIdentifier: accessibilityIdentifier)
	}

	/// Configure a legal extended cell:
	/// - Parameters:
	/// - title, (bold)
	/// - description (bold)
	/// - bulletPoints (attributed string)
	/// - description (normal font)
	func configure(title: NSAttributedString, description: NSAttributedString?, description2: NSAttributedString?, bulletPoints: [NSAttributedString]?, accessibilityIdentifier: String? = nil) {
		
		let label = ENALabel() // get the default font – create fake label
		
		let textBlocks1 = bulletPoints?.map({ $0.bulletPointString(bulletPointFont: label.font) }) ?? []
		var textBlocks2 = [NSAttributedString]()
		if let text = description2 {
			textBlocks2.append(text)
		}
		
		configure(title: title, description1: description, description2: NSAttributedString(), textBlocks1: textBlocks1, textBlocks2: textBlocks2, accessibilityIdentifier: accessibilityIdentifier)
	}


	func configure(title: NSAttributedString, description1: NSAttributedString?, description2: NSAttributedString?, textBlocks1: [NSAttributedString], textBlocks2: [NSAttributedString], accessibilityIdentifier: String? = nil) {
		
		titleLabel.attributedText = title
		descriptionLabel1.attributedText = description1
		descriptionLabel2.attributedText = description2

		descriptionLabel1.isHidden = description1 == nil
		descriptionLabel2.isHidden = description2 == nil
		
		self.accessibilityIdentifier = accessibilityIdentifier
		
		// pruning stack view before setting (new) label
		contentStackView1.removeAllArrangedSubviews()
		contentStackView2.removeAllArrangedSubviews()
		
		textBlocks1.forEach { string in
			let label = ENALabel()
			label.style = .body
			label.numberOfLines = 0
			label.lineBreakMode = .byWordWrapping
			label.attributedText = string
			label.setContentCompressionResistancePriority(.required, for: .vertical)
			label.setContentHuggingPriority(.required, for: .vertical)
			contentStackView1.addArrangedSubview(label)
		}
		
		textBlocks2.forEach { string in
			let label = ENALabel()
			label.style = .body
			label.numberOfLines = 0
			label.lineBreakMode = .byWordWrapping
			label.attributedText = string
			label.setContentCompressionResistancePriority(.required, for: .vertical)
			label.setContentHuggingPriority(.required, for: .vertical)
			contentStackView2.addArrangedSubview(label)
		}
		
		cardView.layoutIfNeeded()
	}

	private func setup() {
		cardView.layer.cornerRadius = 16
	}
}
