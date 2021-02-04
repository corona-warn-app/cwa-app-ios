////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMStaticTextTableViewCell: UITableViewCell, DMConfigureableCell {

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

	// MARK: - Internal

	func configure<T>(cellViewModel: T) {
		guard let cellViewModel = cellViewModel as? DMStaticTextCellViewModel else {
			fatalError("CellViewModel doesn't macht expecations")
		}

		staticTextLabel.text = cellViewModel.staticText
		staticTextLabel.textColor = cellViewModel.textColor
		staticTextLabel.textAlignment = cellViewModel.alignment
		staticTextLabel.font = cellViewModel.font
	}

	// MARK: - Private

	private let staticTextLabel = UILabel()

	private func layoutViews() {
		staticTextLabel.translatesAutoresizingMaskIntoConstraints = false
		staticTextLabel.font = .enaFont(for: .headline)
		staticTextLabel.numberOfLines = 0
		staticTextLabel.textAlignment = .center

		contentView.addSubview(staticTextLabel)

		NSLayoutConstraint.activate([
			staticTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0),
			staticTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0),
			staticTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			staticTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 45.0)
		])

	}

}
#endif
