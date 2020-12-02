////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class LabeledCountriesView: UIView {

	// MARK: - Properties

	var countries: [Country] = [] {
		didSet {
			update()
		}
	}

	let stackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		return stack
	}()
	let flagLabel = ENALabel()
	let nameLabel = ENALabel()

	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	// MARK: - Private

	private func setup() {
		translatesAutoresizingMaskIntoConstraints = false
		stackView.translatesAutoresizingMaskIntoConstraints = false

		flagLabel.numberOfLines = 0
		flagLabel.lineBreakMode = .byCharWrapping // !
		flagLabel.textAlignment = .justified

		nameLabel.numberOfLines = 0
		nameLabel.lineBreakMode = .byWordWrapping // !

		stackView.addArrangedSubview(flagLabel)
		stackView.addArrangedSubview(nameLabel)
		addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	private func update() {
		// All flags as attributed string
		let flagString = NSMutableAttributedString()
		countries
			.compactMap { $0.flag?.withRenderingMode(.alwaysOriginal) }
			.forEach { flag in
				let imageAttachment = NSTextAttachment()
				imageAttachment.image = flag
				imageAttachment.setImageHeight(height: nameLabel.font.pointSize)
				let imageString = NSAttributedString(attachment: imageAttachment)
				flagString.append(imageString)
				flagString.append(NSAttributedString(string: " "))
			}

		let style = NSMutableParagraphStyle()
		style.lineSpacing = 10
		let range = NSRange(location: 0, length: flagString.length)
		flagString.addAttribute(.paragraphStyle, value: style, range: range)
		flagString.addAttribute(.kern, value: 10, range: range)

		flagLabel.attributedText = flagString

		// Country label
		nameLabel.text = countries.map({ $0.localizedName }).joined(separator: ", ")
	}
}
