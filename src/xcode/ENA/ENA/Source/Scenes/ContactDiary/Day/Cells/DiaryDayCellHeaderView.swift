////
// 🦠 Corona-Warn-App
//

import UIKit

final class DiaryDayCellHeaderView: UIView {
	
	// MARK: - Init
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		// self
		translatesAutoresizingMaskIntoConstraints = false
		// checkboxImageView
		iconView = UIImageView()
		iconView.contentMode = .scaleAspectFit
		iconView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(iconView)
		// label
		titleLabel = ENALabel()
		titleLabel.style = .body
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)
		// line
		line = SeperatorLineLayer()
		layer.insertSublayer(line, at: 0)
		// activate constrinats
		NSLayoutConstraint.activate([
			// checkboxImageView
			iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13),
			iconView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -13),
			iconView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
			iconView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
			iconView.widthAnchor.constraint(equalToConstant: 32),
			iconView.heightAnchor.constraint(equalToConstant: 32),
			// label
			titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 15),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14),
			titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
			titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: bounds.height))
		path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
		line.path = path.cgPath
		line.opacity = 1
	}
	
	// MARK: - Internal
	
	var iconView: UIImageView!
	var titleLabel: ENALabel!
	var line: SeperatorLineLayer!
	
}
