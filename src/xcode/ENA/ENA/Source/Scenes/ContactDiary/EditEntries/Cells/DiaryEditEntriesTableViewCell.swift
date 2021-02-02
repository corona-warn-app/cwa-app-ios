////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryEditEntriesTableViewCell: UITableViewCell {

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		addBackground()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		addBackground()
	}

	// MARK: - Internal

	func configure(model: DiaryEditEntriesCellModel) {
		label.text = model.text

	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!

	private func addBackground() {
		let _backgroundView = UIView(frame: .zero)
		_backgroundView.translatesAutoresizingMaskIntoConstraints = false
		_backgroundView.layer.cornerRadius = 14
		_backgroundView.backgroundColor = .enaColor(for: .cellBackground)
		_backgroundView.tintColor = .enaColor(for: .tint)
		insertSubview(_backgroundView, belowSubview: contentView)

		NSLayoutConstraint.activate([
			_backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
			_backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			_backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			_backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
		])
	}
}
