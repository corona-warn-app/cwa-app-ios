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
		buttonAction = cellViewModel.action
		button.setTitle(cellViewModel.text, for: .normal)
		button.setTitleColor(cellViewModel.textColor, for: .normal)
		let backgroundImage = UIImage.with(color: cellViewModel.backgroundColor)
		button.setBackgroundImage(backgroundImage, for: .normal)
		button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let button = UIButton(type: .custom)
	private var buttonAction: (() -> Void)?

	private func layoutViews() {
		backgroundColor = .clear

		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .enaFont(for: .body)
		button.titleLabel?.textAlignment = .center
		button.layer.cornerRadius = 8.0
		button.layer.masksToBounds = true
		button.layer.borderWidth = 1.0
		button.layer.borderColor = UIColor.white.cgColor

		contentView.addSubview(button)

		NSLayoutConstraint.activate([
			button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
			button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
			button.topAnchor.constraint(equalTo: contentView.topAnchor),
			button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35.0)
		])

	}

	@objc
	private func didTapButton() {
		buttonAction?()
	}

}
