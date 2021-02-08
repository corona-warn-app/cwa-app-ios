////
// 🦠 Corona-Warn-App
//

import UIKit

final class SelectValueTableViewCell: UITableViewCell {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none

		layoutViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public

	func configure(_ cellViewModel: SelectValueCellViewModel) {
		selectableValueLabel.text = cellViewModel.text
		accessoryView = UIImageView(image: cellViewModel.checkmarkImage)
	}

	// MARK: - Internal

	static var reuseIdentifier: String {
		String(describing: self)
	}
	// MARK: - Private

	private let selectableValueLabel = ENALabel()

	private func layoutViews() {
		backgroundColor = .enaColor(for: .background)

		selectableValueLabel.translatesAutoresizingMaskIntoConstraints = false
		selectableValueLabel.font = .enaFont(for: .body)
		selectableValueLabel.textAlignment = .left

		contentView.addSubview(selectableValueLabel)

		NSLayoutConstraint.activate([
			selectableValueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
			selectableValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
			selectableValueLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			selectableValueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
		])

	}

}
