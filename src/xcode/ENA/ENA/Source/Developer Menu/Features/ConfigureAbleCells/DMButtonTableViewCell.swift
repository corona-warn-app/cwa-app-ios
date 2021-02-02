////
// 🦠 Corona-Warn-App
//

import UIKit

class DMButtonTableViewCell: UITableViewCell, ConfigureAbleCell {

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

	// MARK: - Overrides

	// MARK: - Protocol ConfigureAbleCell

	func configure<T>(cellViewModel: T) {
		guard let cellViewModel = cellViewModel as? DMButtonCellViewModel else {
			fatalError("CellViewModel doesn't macht expecations")
		}
		buttonLabel.text = cellViewModel.text
		buttonLabel.textColor = cellViewModel.textColor
		buttonLabel.backgroundColor = cellViewModel.backgroundColor
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private
	private let buttonLabel = UILabel()

	private func layoutViews() {
		backgroundColor = .clear

		buttonLabel.translatesAutoresizingMaskIntoConstraints = false
		buttonLabel.font = .enaFont(for: .body)
		buttonLabel.numberOfLines = 0
		buttonLabel.textAlignment = .center
		buttonLabel.layer.cornerRadius = 8.0
		buttonLabel.layer.masksToBounds = true
		buttonLabel.layer.borderWidth = 1.0
		buttonLabel.layer.borderColor = UIColor.white.cgColor


//		if #available(iOS 13.0, *) {
//			buttonLabel.layer.cornerCurve = .circular
//		}

		contentView.addSubview(buttonLabel)

		NSLayoutConstraint.activate([
			buttonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
			buttonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
			buttonLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			buttonLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35.0)
		])

	}

}
