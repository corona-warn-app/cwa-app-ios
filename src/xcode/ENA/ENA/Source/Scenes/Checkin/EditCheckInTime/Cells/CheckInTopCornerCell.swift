////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInTopCornerCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public

	// MARK: - Internal

	func configure(_ model: String) {
		noticeLabel.text = model
	}

	// MARK: - Private

	private let typeLabel = ENALabel()

	private let noticeLabel = ENALabel()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .darkBackground)
		tileView.layer.cornerRadius = 12.0
		tileView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

		contentView.addSubview(tileView)

		NSLayoutConstraint.activate([
			tileView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3.0),
			tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20.0)
		])
	}


}
