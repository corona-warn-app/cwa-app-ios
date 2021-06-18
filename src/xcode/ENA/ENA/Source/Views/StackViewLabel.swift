////
// 🦠 Corona-Warn-App
//

import UIKit

class StackViewLabel: UIView {
	
	// MARK: - Init
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}
	
	// MARK: - Internal
	
	var text: String? {
		get { label.text }
		set { label.text = newValue }
	}
	
	var font: UIFont {
		get { label.font }
		set { label.font = newValue }
	}
	
	var numberOfLines: Int {
		get { label.numberOfLines }
		set { label.numberOfLines = newValue }
	}
	
	var textAlignment: NSTextAlignment {
		get { label.textAlignment }
		set { label.textAlignment = newValue }
	}
	
	var adjustsFontSizeToFitWidth: Bool {
		get { label.adjustsFontSizeToFitWidth }
		set { label.adjustsFontSizeToFitWidth = newValue }
	}
	
	var onAccessibilityFocus: (() -> Void)? {
		get { label.onAccessibilityFocus }
		set { label.onAccessibilityFocus = newValue }
	}
	
	var allowsDefaultTighteningForTruncation: Bool {
		get { label.allowsDefaultTighteningForTruncation }
		set { label.allowsDefaultTighteningForTruncation = newValue }
	}
	
	var textColor: UIColor {
		get { label.textColor }
		set { label.textColor = newValue }
	}
	
	var style: ENALabel.Style? {
		get { label.style }
		set { label.style = newValue }
	}
	
	// MARK: - Private
	
	private var label: ENALabel!
	
	private func setupView() {
		
		backgroundColor = nil
		
		label = ENALabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)
		
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: leadingAnchor),
			label.trailingAnchor.constraint(equalTo: trailingAnchor),
			label.topAnchor.constraint(equalTo: topAnchor),
			label.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
}
