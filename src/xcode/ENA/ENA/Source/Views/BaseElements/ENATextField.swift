////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class ENATextField: UITextField {

	// MARK: - Init

	convenience init() {
		self.init(frame: .zero)
	}

	init(frame: CGRect, deltaXInset: CGFloat = 14.0) {
		self.deltaXInset = deltaXInset

		super.init(frame: frame)

		setupLayout()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		setupLayout()
	}

	// MARK: - Overrides
	
	override var accessibilityIdentifier: String? {
		didSet {
			guard let identifier = accessibilityIdentifier else { return }
			setupClearButtonAccessibility(for: identifier)
		}
	}

	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return super.textRect(forBounds: bounds)
			.inset(by: UIEdgeInsets(top: 0, left: deltaXInset, bottom: 0, right: deltaXInset))
	}

	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}

	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}

	override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
		return super.clearButtonRect(forBounds: bounds)
			.inset(by: UIEdgeInsets(top: 0, left: -deltaXInset, bottom: 0, right: deltaXInset))
	}

	override var placeholder: String? {
		didSet {
			guard let placeholder = placeholder else {
				attributedPlaceholder = nil
				return
			}

			attributedPlaceholder = NSAttributedString(
				string: placeholder,
				attributes: [
					.foregroundColor: UIColor.enaColor(for: .textPrimary2)
				]
			)
		}
	}

	// MARK: - Internal

	@IBInspectable var deltaXInset: CGFloat = 14.0

	@IBInspectable var maxLength: Int = 0

	// MARK: - Private

	private func setupLayout() {
		borderStyle = .none
		backgroundColor = .enaColor(for: .textField)

		textColor = .enaColor(for: .textPrimary1)

		layer.borderWidth = 0
		layer.masksToBounds = true
		layer.cornerRadius = 14.0

		addTarget(self, action: #selector(applyTextConstraints), for: .editingChanged)
	}

	@objc
	private func applyTextConstraints() {
		guard let text = text, maxLength > 0 else {
			return
		}

		self.text = String(text.prefix(maxLength))
	}

	private func setupClearButtonAccessibility(for identifier: String) {
		if let clearButton = value(forKey: "clearButton") as? UIButton {
			clearButton.isAccessibilityElement = true
			clearButton.accessibilityIdentifier = "\(identifier).ClearButton"
			print("clearButton.accessibilityIdentifier: ", clearButton.accessibilityIdentifier)
		}
	}
}
