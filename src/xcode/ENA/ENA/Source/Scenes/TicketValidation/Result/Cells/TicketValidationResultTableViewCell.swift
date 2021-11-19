//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TicketValidationResultTableViewCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func prepareForReuse() {
		super.prepareForReuse()

		cellModel = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorderColor()
	}

	// MARK: - Internal

	func configure(with cellModel: TicketValidationResultCellModel, onUpdate: @escaping () -> Void) {
		iconImageView.image = cellModel.iconImage
		itemDetailsLabel.text = cellModel.itemDetails
		keyValueAttributedLabel.attributedText = cellModel.keyValueAttributedString

		self.cellModel = cellModel
	}

	// MARK: - Private

	private let backgroundContainerView: UIView = {
		let backgroundContainerView = UIView()
		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.backgroundColor = .enaColor(for: .background)
		backgroundContainerView.layer.borderWidth = 1
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true

		return backgroundContainerView
	}()

	private let iconImageView: UIImageView = {
		let iconImageView = UIImageView()
		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		iconImageView.setContentHuggingPriority(.required, for: .horizontal)

		return iconImageView
	}()

	private let itemDetailsLabel: ENALabel = {
		let itemDetailsLabel = ENALabel(style: .body)
		itemDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
		itemDetailsLabel.numberOfLines = 0
		itemDetailsLabel.textColor = .enaColor(for: .textPrimary1)

		return itemDetailsLabel
	}()

	private let keyValueAttributedLabel: UILabel = {
		let keyValueAttributedLabel = UILabel()
		keyValueAttributedLabel.translatesAutoresizingMaskIntoConstraints = false
		keyValueAttributedLabel.numberOfLines = 0

		return keyValueAttributedLabel
	}()

	private var cellModel: TicketValidationResultCellModel?

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		updateBorderColor()
		setupViewHierarchy()
	}

	private func setupViewHierarchy() {
		contentView.addSubview(backgroundContainerView)

		backgroundContainerView.addSubview(iconImageView)
		backgroundContainerView.addSubview(itemDetailsLabel)
		backgroundContainerView.addSubview(keyValueAttributedLabel)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				iconImageView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				iconImageView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				iconImageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 32.0),
				iconImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30.0),

				itemDetailsLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12.0),
				itemDetailsLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: -4.0),
				itemDetailsLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				keyValueAttributedLabel.leadingAnchor.constraint(equalTo: itemDetailsLabel.leadingAnchor),
				keyValueAttributedLabel.topAnchor.constraint(equalTo: itemDetailsLabel.bottomAnchor, constant: 16.0),
				keyValueAttributedLabel.trailingAnchor.constraint(equalTo: itemDetailsLabel.trailingAnchor),
				keyValueAttributedLabel.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0)
			]
		)
	}

	private func updateBorderColor() {
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
	}

}
