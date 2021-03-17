////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryEntryTextField: UITextField {

	// MARK: - Init

	init(frame: CGRect, deltaXInset: CGFloat = 14.0) {
		self.deltaXInset = deltaXInset
		super.init(frame: frame)

		borderStyle = .none
		backgroundColor = .enaColor(for: ENAColor.textField)

		layer.borderColor = UIColor.enaColor(for: ENAColor.cellBackground).cgColor
		layer.borderWidth = 1
		layer.masksToBounds = true
		layer.cornerRadius = 14.0
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return super.textRect(forBounds: bounds).insetBy(dx: deltaXInset, dy: 0.0)
	}

	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}

	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}

	// MARK: - Internal

	// MARK: - Private

	private let deltaXInset: CGFloat

}
