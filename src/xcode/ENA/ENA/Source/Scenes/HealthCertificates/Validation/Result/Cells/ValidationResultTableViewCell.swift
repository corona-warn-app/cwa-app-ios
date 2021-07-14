//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ValidationResultTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorderColor()
	}

	// MARK: - Internal

	func configure(with cellModel: ValidationResultCellModel, onUpdate: @escaping () -> Void) {
		iconImageView.image = cellModel.iconImage
		ruleDescriptionLabel.text = cellModel.ruleDescription
		ruleTypeDescriptionLabel.text = cellModel.ruleTypeDescription
		keyValueAttributedLabel.attributedText = cellModel.keyValueAttributedString

		// only needed if keyValuePairs get updated while the cell is shown.
		// this is why we drop the first callback
		cellModel.$keyValuePairs
			.dropFirst()
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				self?.keyValueAttributedLabel.attributedText = cellModel.keyValueAttributedString
				onUpdate()
			}
			.store(in: &subscriptions)
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let iconImageView = UIImageView()
	private let ruleDescriptionLabel = ENALabel(style: .body)
	private let ruleTypeDescriptionLabel = ENALabel(style: .footnote)
	private let keyValueAttributedLabel = UILabel()
	private var subscriptions = Set<AnyCancellable>()

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.backgroundColor = .enaColor(for: .background)
		backgroundContainerView.layer.borderWidth = 1
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		updateBorderColor()
		contentView.addSubview(backgroundContainerView)

		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		iconImageView.setContentHuggingPriority(.required, for: .horizontal)
		backgroundContainerView.addSubview(iconImageView)

		ruleDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		ruleDescriptionLabel.numberOfLines = 0
		ruleDescriptionLabel.textColor = .enaColor(for: .textPrimary1)
		backgroundContainerView.addSubview(ruleDescriptionLabel)

		ruleTypeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		ruleTypeDescriptionLabel.numberOfLines = 0
		ruleTypeDescriptionLabel.textColor = .enaColor(for: .textPrimary2)
		backgroundContainerView.addSubview(ruleTypeDescriptionLabel)

		keyValueAttributedLabel.translatesAutoresizingMaskIntoConstraints = false
		keyValueAttributedLabel.numberOfLines = 0
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

				ruleDescriptionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12.0),
				ruleDescriptionLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: -4.0),
				ruleDescriptionLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				ruleTypeDescriptionLabel.leadingAnchor.constraint(equalTo: ruleDescriptionLabel.leadingAnchor),
				ruleTypeDescriptionLabel.topAnchor.constraint(equalTo: ruleDescriptionLabel.bottomAnchor, constant: 4.0),
				ruleTypeDescriptionLabel.trailingAnchor.constraint(equalTo: ruleDescriptionLabel.trailingAnchor),

				keyValueAttributedLabel.leadingAnchor.constraint(equalTo: ruleDescriptionLabel.leadingAnchor),
				keyValueAttributedLabel.topAnchor.constraint(equalTo: ruleTypeDescriptionLabel.bottomAnchor, constant: 16.0),
				keyValueAttributedLabel.trailingAnchor.constraint(equalTo: ruleDescriptionLabel.trailingAnchor),
				keyValueAttributedLabel.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0)
			]
		)
		accessibilityElements = [ruleDescriptionLabel]
	}

	private func updateBorderColor() {
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
	}

}
