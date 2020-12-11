////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryEntryTextFiled: UITextField {

	// MARK: - Init

	init(frame: CGRect, xDeltaInset: CGFloat) {
		self.xDeltaInset = xDeltaInset
		super.init(frame: frame)

		borderStyle = .none
		backgroundColor = .enaColor(for: ENAColor.cellBackground)

		layer.borderColor = UIColor.enaColor(for: ENAColor.cellBackground).cgColor
		layer.borderWidth = 1
		layer.masksToBounds = true
		layer.cornerRadius = 8.0
		layer.masksToBounds = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds).insetBy(dx: xDeltaInset, dy: 0.0)
	}

	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds).insetBy(dx: xDeltaInset, dy: 0.0)
	}

	// MARK: - Internal

	// MARK: - Private

	private let xDeltaInset: CGFloat

}
