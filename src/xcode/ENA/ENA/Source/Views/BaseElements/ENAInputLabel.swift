////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class ENATanInputLabel: UILabel {

	// MARK: - Init

	init(
		validColor: UIColor?,
		invalidColor: UIColor?
	) {
		self.validColor = validColor
		self.invalidColor = invalidColor
		super.init(frame: .zero)
		updateAccessibilityLabel()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override var text: String? { didSet { updateAccessibilityLabel() } }

	override var layoutMargins: UIEdgeInsets { didSet { invalidateIntrinsicContentSize() ; setNeedsLayout() } }

	override var intrinsicContentSize: CGSize {
		let size = super.intrinsicContentSize
		return CGSize(width: size.width + layoutMargins.left + layoutMargins.right, height: size.height + layoutMargins.top + layoutMargins.bottom)
	}

	override func draw(_ rect: CGRect) {
		let textColor = self.textColor
		self.textColor = isValid ? textColor : (invalidColor ?? textColor)

		super.draw(rect)

		self.textColor = textColor

		if isEmpty || !isValid {
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

	// MARK: - Internal

	let validColor: UIColor?
	let invalidColor: UIColor?

	var isEmpty: Bool { false != text?.isEmpty }
	var isValid: Bool = true { didSet { setNeedsDisplay() ; updateAccessibilityLabel() } }

	func clear() {
		text = ""
		isValid = true
	}

	// MARK: - Private

	private let lineWidth: CGFloat = 3
	private var lineColor: UIColor { (isValid ? validColor : invalidColor) ?? textColor }

	private func updateAccessibilityLabel() {
		accessibilityLabel = AppStrings.ExposureSubmissionTanEntry.textField
		accessibilityValue = (text?.isEmpty ?? true) ? AppStrings.ENATanInput.empty : text

		if !isValid {
			accessibilityLabel = String(format: AppStrings.ENATanInput.invalidCharacter, accessibilityLabel ?? "")
		}
	}
}
