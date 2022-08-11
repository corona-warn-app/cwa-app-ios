//
// 🦠 Corona-Warn-App
//

import UIKit

class DynamicTableViewRoundedCell: UITableViewCell {

	// MARK: - View elements.

	lazy var title = ENALabel(frame: .zero)
	lazy var body = ENALabel(frame: .zero)
	lazy var insetView = UIView(frame: .zero)
	lazy var iconStackView = UIStackView(frame: .zero)
	lazy var button = ENAButton(frame: .zero)

	// MARK: - Callbacks.

	private var buttonTapped: (() -> Void)?

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.autoresizingMask = .flexibleHeight
	}

	// swiftlint:disable function_parameter_count
	private func setup(
		titleStyle: ENALabel.Style,
		bodyStyle: ENALabel.Style,
		textColor: ENAColor,
		bgColor: ENAColor,
		icons: [UIImage],
		buttonTitle: String?,
		buttonTapped: (() -> Void)?,
		buttonAccessibilityIdentifier: String?
	) {

		// MARK: - General cell setup.
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)

		// MARK: - Add inset view
		insetView.backgroundColor = .enaColor(for: bgColor)
		insetView.layer.cornerRadius = 16.0

		// MARK: - Title adjustment.
		title.style = titleStyle
		title.textColor = .enaColor(for: textColor)
		title.lineBreakMode = .byWordWrapping
		title.numberOfLines = 0

		// MARK: - Body adjustment.
		body.style = bodyStyle
		body.textColor = .enaColor(for: textColor)
		body.lineBreakMode = .byWordWrapping
		body.numberOfLines = 0

		// MARK: - Stackview adjustment.
		if !icons.isEmpty {
			iconStackView = UIStackView(frame: .zero)
			iconStackView.axis = .horizontal
			iconStackView.spacing = 8
			iconStackView.distribution = .fillProportionally
			for icon in icons {
				iconStackView.addArrangedSubview(UIImageView(image: icon))
			}
		}

		// MARK: - Button adjustment.
		if let buttonTitle = buttonTitle {
			button.setTitle(buttonTitle, for: .normal)
			button.titleLabel?.numberOfLines = 0
			button.titleLabel?.lineBreakMode = .byWordWrapping
			let tapHandler = UITapGestureRecognizer(target: self, action: #selector(didTapButton(sender:)))
			button.addGestureRecognizer(tapHandler)
			self.buttonTapped = buttonTapped
			button.accessibilityIdentifier = buttonAccessibilityIdentifier
		}

		UIView.translatesAutoresizingMaskIntoConstraints(for: [
			insetView, title, body, iconStackView, button
		], to: false)

		addSubview(insetView)
		insetView.addSubviews([title, body, iconStackView, button])
	}

	private func setupConstraints() {
		let marginGuide = contentView.layoutMarginsGuide
		contentView.addSubview(insetView)
		
		// Need top opt-out the constraints to avoid empty spaces if title or body are not set but the button.
		let titleTopConstraintValue: CGFloat = title.attributedText == nil ? 0 : 20
		let bodyTopConstraintValue: CGFloat = body.attributedText == nil ? 0 : 16
		
		NSLayoutConstraint.activate([
			insetView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor),
			insetView.topAnchor.constraint(equalTo: marginGuide.topAnchor),
			insetView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor),
			insetView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor),
			title.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16),
			title.topAnchor.constraint(equalTo: insetView.topAnchor, constant: titleTopConstraintValue),
			body.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16),
			body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: bodyTopConstraintValue),
			body.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16)
		])

		if iconStackView.subviews.isEmpty {
			title.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16).isActive = true
			iconStackView.removeFromSuperview()
		} else {
			NSLayoutConstraint.activate([
				title.trailingAnchor.constraint(equalTo: iconStackView.leadingAnchor, constant: -32),
				iconStackView.topAnchor.constraint(equalTo: insetView.topAnchor, constant: 20),
				iconStackView.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16)
			])

			iconStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
			iconStackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		}
		
		// Need top opt-out the constraints to avoid empty spaces if title or body are not set but the button.
		let bodyBottomConstraintWithButtonValue: CGFloat = body.attributedText == nil ? 0 : -37
		let bodyBottomConstraintWithoutButtonValue: CGFloat = body.attributedText == nil ? 0 : -16
		
		if buttonTapped != nil {
			NSLayoutConstraint.activate([
				body.bottomAnchor.constraint(equalTo: button.topAnchor, constant: bodyBottomConstraintWithButtonValue),
				button.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16),
				button.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16),
				button.bottomAnchor.constraint(equalTo: insetView.bottomAnchor, constant: -16)
			])
			button.setContentHuggingPriority(.defaultLow, for: .vertical)
		} else {
			body.bottomAnchor.constraint(equalTo: insetView.bottomAnchor, constant: bodyBottomConstraintWithoutButtonValue).isActive = true
			button.removeFromSuperview()
		}
	}

	func configure(
		title: NSMutableAttributedString? = nil,
		titleStyle: ENALabel.Style = .headline,
		body: NSMutableAttributedString? = nil,
		bodyStyle: ENALabel.Style = .body,
		textColor: ENAColor,
		bgColor: ENAColor,
		icons: [UIImage] = [],
		buttonTitle: String? = nil,
		buttonTapped: (() -> Void)? = nil,
		buttonAccessibilityIdentifier: String? = nil
	) {
		self.title.attributedText = title
		self.body.attributedText = body

		setup(
			titleStyle: titleStyle,
			bodyStyle: bodyStyle,
			textColor: textColor,
			bgColor: bgColor,
			icons: icons,
			buttonTitle: buttonTitle,
			buttonTapped: buttonTapped,
			buttonAccessibilityIdentifier: buttonAccessibilityIdentifier
		)
		setupConstraints()
	}

	// MARK: - Helper methods
	@objc
	private func didTapButton(sender: UITapGestureRecognizer) {
		buttonTapped?()
	}

}
