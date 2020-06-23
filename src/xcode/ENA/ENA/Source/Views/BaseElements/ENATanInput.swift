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

import Foundation
import UIKit

@objc
protocol ENATanInputDelegate: AnyObject {
	@objc
	optional func enaTanInput(_ tanInput: ENATanInput, didChange text: String, isValid: Bool, isChecksumValid: Bool, isBlocked: Bool)
	@objc
	optional func enaTanInputDidBeginEditing(_ tanInput: ENATanInput)
	@objc
	optional func enaTanInputDidEndEditing(_ tanInput: ENATanInput)
	@objc
	optional func enaTanInputDidTapReturn(_ tanInput: ENATanInput) -> Bool
}

@IBDesignable
class ENATanInput: UIControl {
	@IBInspectable var textColor: UIColor = .enaColor(for: .textPrimary1)
	@IBInspectable var validColor: UIColor = .enaColor(for: .textSemanticGray)
	@IBInspectable var invalidColor: UIColor = .enaColor(for: .textSemanticRed)
	@IBInspectable var boxColor: UIColor = .enaColor(for: .separator)

	@IBInspectable private var enaFontStyle: String?

	@IBInspectable var spacing: CGFloat = 3
	@IBInspectable var verticalSpacing: CGFloat = 8
	@IBInspectable var cornerRadius: CGFloat = 4

	@IBInspectable private var groups: String = "3,3,4"
	@IBInspectable private var allowedCharacters: String = "23456789ABCDEFGHJKMNPQRSTUVWXYZ"

	weak var delegate: ENATanInputDelegate?

	let boxInsets = UIEdgeInsets(top: 10, left: 1, bottom: 10, right: 1)
	let verticalBoxInsets = UIEdgeInsets(top: 13, left: 8, bottom: 13, right: 8)

	private var stackView: UIStackView!
	private var stackViewWidthConstraint: NSLayoutConstraint!
	private var boxWidthConstraint: NSLayoutConstraint!
	private var boxHeightConstraint: NSLayoutConstraint!

	private var stackViews: [UIStackView] { stackView.arrangedSubviews.compactMap({ $0 as? UIStackView }) }
	private var labels: [UILabel] { stackViews.flatMap({ $0.arrangedSubviews }).compactMap({ $0 as? UILabel }) }
	private var inputLabels: [ENATanInputLabel] { labels.compactMap({ $0 as? ENATanInputLabel }) }

	lazy var fontStyle: ENAFont = ENAFont(rawValue: enaFontStyle ?? "") ?? .title2
	lazy var font = UIFont.enaFont(for: fontStyle)

	var digitGroups: [Int] { groups.split(separator: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }) }
	var numberOfDigits: Int { digitGroups.reduce(0) { $0 + $1 } }

	lazy var characterSet: CharacterSet = CharacterSet(charactersIn: self.allowedCharacters.uppercased())

	var keyboardType: UIKeyboardType = .asciiCapable
	var returnKeyType: UIReturnKeyType = .next
	var textContentType: UITextContentType = .oneTimeCode

	var hasText: Bool { !text.isEmpty }

	override var canBecomeFirstResponder: Bool { true }

	private(set) var text = ""
	var count: Int { text.count }
	// swiftlint:disable:next empty_count
	var isEmpty: Bool { count == 0 }
	var isValid: Bool { count == numberOfDigits }
	var isChecksumValid: Bool { verifyChecksum() }
	private(set) var isInputBlocked: Bool = false
}

extension ENATanInput {
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		setup()
		setupAccessibility()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		if stackView.axis != .vertical && stackView.bounds.width > bounds.width {
			updateAxis(.vertical)
		} else if stackView.axis == .horizontal && !stackViewWidthConstraint.isActive {
			stackViewWidthConstraint.isActive = true
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateAxis(.horizontal)
	}
}

extension ENATanInput {
	@discardableResult
	override func becomeFirstResponder() -> Bool {
		delegate?.enaTanInputDidBeginEditing?(self)
		return super.becomeFirstResponder()
	}

	@discardableResult
	override func resignFirstResponder() -> Bool {
		delegate?.enaTanInputDidEndEditing?(self)
		return super.resignFirstResponder()
	}
}

extension ENATanInput {
	private func setupAccessibility() {
		labels.forEach { label in
			label.isAccessibilityElement = false
		}

		inputLabels.enumerated().forEach { index, label in
			label.isAccessibilityElement = true
			label.accessibilityTraits = .updatesFrequently
			label.accessibilityHint = String(format: AppStrings.ENATanInput.characterIndex, index + 1, numberOfDigits)
		}
	}
}

extension ENATanInput {
	private func setup() {
		guard stackView == nil else { return }

		stackView = UIStackView()

		stackView.isUserInteractionEnabled = false
		stackView.alignment = .fill

		// Generate character groups
		for (index, numberOfDigitsInGroup) in digitGroups.enumerated() {
			let groupView = createGroup(count: numberOfDigitsInGroup, hasDash: index < digitGroups.count - 1)
			stackView.addArrangedSubview(groupView)
		}

		// Constrain group heights
		if let firstStackView = stackViews.first {
			stackViews[1...].forEach { $0.heightAnchor.constraint(equalTo: firstStackView.heightAnchor).isActive = true }
		}

		// Constrain character labels
		if let firstLabel = inputLabels.first {
			boxWidthConstraint = firstLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
			boxHeightConstraint = firstLabel.heightAnchor.constraint(equalToConstant: 0)
			inputLabels[1...].forEach { $0.widthAnchor.constraint(equalTo: firstLabel.widthAnchor).isActive = true }
		}

		addSubview(stackView)
		stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		stackViewWidthConstraint = stackView.widthAnchor.constraint(equalTo: widthAnchor)

		UIView.translatesAutoresizingMaskIntoConstraints(for: [stackView] + stackViews + labels, to: false)

		updateAxis(.horizontal)

		addTapTargetToBecomeFirstResponder()
	}

	private func createGroup(count: Int, hasDash: Bool) -> UIStackView {
		let stackView = UIStackView()

		stackView.spacing = spacing
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fill

		for _ in 0..<count { stackView.addArrangedSubview(createLabel()) }
		if hasDash { stackView.addArrangedSubview(createDash()) }

		return stackView
	}

	private func createLabel() -> ENATanInputLabel {
		let label = ENATanInputLabel()

		label.textColor = textColor
		label.validColor = validColor
		label.invalidColor = invalidColor

		label.clipsToBounds = true
		label.backgroundColor = boxColor
		label.layer.cornerRadius = cornerRadius

		label.font = font
		label.adjustsFontForContentSizeCategory = true

		label.textAlignment = .center
		label.lineBreakMode = .byClipping

		return label
	}

	private func createDash() -> UILabel {
		let label = UILabel()

		label.font = font
		label.adjustsFontForContentSizeCategory = true

		label.textColor = validColor
		label.textAlignment = .center
		label.text = "-"

		return label
	}

	private func updateAxis(_ axis: NSLayoutConstraint.Axis) {
		stackView.axis = axis

		let insets: UIEdgeInsets

		if axis == .horizontal {
			stackView.spacing = spacing
			stackView.distribution = .fill
			insets = boxInsets
		} else {
			stackView.spacing = verticalSpacing
			stackView.distribution = .fillEqually
			insets = verticalBoxInsets
		}

		inputLabels.forEach { $0.layoutMargins = insets }

		stackViewWidthConstraint.isActive = false

		updateBoxSize()
	}

	private func updateBoxSize() {
		let label = UILabel()
		label.adjustsFontForContentSizeCategory = true
		label.font = .enaFont(for: fontStyle)
		label.text = "W" // Largest reference character

		let size = label.intrinsicContentSize
		let insets = stackView.axis == .horizontal ? boxInsets : verticalBoxInsets

		boxWidthConstraint.constant = size.width + insets.left + insets.right
		boxHeightConstraint.constant = size.height + insets.top + insets.bottom

		boxWidthConstraint.isActive = true
		boxHeightConstraint.isActive = true
	}

	private func addTapTargetToBecomeFirstResponder() {
		addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
	}
}

extension ENATanInput: UIKeyInput {
	func insertText(_ text: String) {
		if text == "\n" {
			if delegate?.enaTanInputDidTapReturn?(self) ?? true { _ = resignFirstResponder() }
			return
		}

		for character in text.trimmingCharacters(in: .whitespacesAndNewlines).map({ $0.uppercased() }) {
			guard !isValid && !isInputBlocked else { return }

			let label = inputLabels[count]

			self.text += "\(character)"
			label.text = "\(character)"

			label.isValid = character.rangeOfCharacter(from: characterSet) != nil
			isInputBlocked = !label.isValid
		}

		delegate?.enaTanInput?(self, didChange: self.text, isValid: isValid, isChecksumValid: isChecksumValid, isBlocked: isInputBlocked)
	}

	func deleteBackward() {
		guard !isEmpty else { return }
		isInputBlocked = false

		text = String(text[..<text.index(before: text.endIndex)])
		inputLabels[count].clear()

		delegate?.enaTanInput?(self, didChange: self.text, isValid: isValid, isChecksumValid: isChecksumValid, isBlocked: isInputBlocked)
	}

	func clear() {
		inputLabels.forEach { $0.clear() }
		text = ""

		delegate?.enaTanInput?(self, didChange: self.text, isValid: isValid, isChecksumValid: isChecksumValid, isBlocked: isInputBlocked)
	}
}

private class ENATanInputLabel: UILabel {
	private let lineWidth: CGFloat = 3

	var validColor: UIColor?
	var invalidColor: UIColor?

	var isValid: Bool = true { didSet { setNeedsDisplay() ; updateAccessibilityLabel() } }

	override var text: String? { didSet { updateAccessibilityLabel() } }

	private var lineColor: UIColor { (isValid ? validColor : invalidColor) ?? textColor }

	override var layoutMargins: UIEdgeInsets { didSet { invalidateIntrinsicContentSize() ; setNeedsLayout() } }

	override var intrinsicContentSize: CGSize {
		let size = super.intrinsicContentSize
		return CGSize(width: size.width + layoutMargins.left + layoutMargins.right, height: size.height + layoutMargins.top + layoutMargins.bottom)
	}

	convenience init() {
		self.init(frame: .zero)
		updateAccessibilityLabel()
	}

	override func draw(_ rect: CGRect) {
		let textColor = self.textColor
		self.textColor = isValid ? textColor : (invalidColor ?? textColor)

		super.draw(rect)

		self.textColor = textColor

		if false != text?.isEmpty {
			guard let context = UIGraphicsGetCurrentContext() else { return }
			context.setLineWidth(lineWidth)
			context.setStrokeColor(lineColor.cgColor)
			context.move(to: CGPoint(x: 0, y: bounds.height - lineWidth / 2))
			context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - lineWidth / 2))
			context.strokePath()
		}
	}

	override func drawText(in rect: CGRect) {
		let textSize = super.intrinsicContentSize
		let point = CGPoint(x: (bounds.width - textSize.width) / 2, y: (bounds.height - textSize.width) / 2)
		let insets = UIEdgeInsets(top: point.y, left: point.x + 0.5, bottom: point.y, right: point.x - 0.5)
		super.drawText(in: rect.inset(by: insets))
	}

	func clear() {
		text = ""
		isValid = true
	}

	private func updateAccessibilityLabel() {
		accessibilityLabel = AppStrings.ExposureSubmissionTanEntry.textField
		accessibilityValue = (text?.isEmpty ?? true) ? AppStrings.ENATanInput.empty : text

		if !isValid {
			accessibilityLabel = String(format: AppStrings.ENATanInput.invalidCharacter, accessibilityLabel ?? "")
		}
	}
}

private extension ENATanInput {
	func verifyChecksum() -> Bool {
		guard isValid else { return false }

		let start = text.index(text.startIndex, offsetBy: 0)
		let end = text.index(text.startIndex, offsetBy: text.count - 2)
		let testString = String(text[start...end])
		return text.last == calculateChecksum(input: testString)
	}

	func calculateChecksum(input: String) -> Character? {
		let hash = Hasher.sha256(input)
		switch hash.first?.uppercased() {
		case "0": return "G"
		case "1": return "H"
		case .some(let c): return Character(c)
		default: return nil
		}
	}
}
