////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class VaccinationHintTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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

		updateBorderWidth()
	}

	// MARK: - Internal

	func configure(with cellModel: VaccinationHintCellModel) {
		titleLabel.text = cellModel.title
		subtitleLabel.text = cellModel.subtitle

		descriptionLabel.text = cellModel.description
	}

	// MARK: - Private

	private let backgroundContainerView: UIView = {
		let backgroundContainerView = UIView()
		backgroundContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true

		return backgroundContainerView
	}()

	private let contentStackView: UIStackView = {
		let contentStackView = UIStackView()
		contentStackView.axis = .vertical
		contentStackView.spacing = 6

		return contentStackView
	}()

	private let titleLabel: ENALabel = {
		let titleLabel = ENALabel(style: .headline)
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .enaColor(for: .textPrimary1)

		return titleLabel
	}()

	private let subtitleLabel: ENALabel = {
		let subtitleLabel = ENALabel(style: .body)
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textColor = .enaColor(for: .textPrimary2)

		return subtitleLabel
	}()

	private let descriptionLabel: ENALabel = {
		let descriptionLabel = ENALabel(style: .body)
		descriptionLabel.numberOfLines = 0

		return descriptionLabel
	}()

	private let linkTextView: UITextView = {
		let linkTextView = UITextView()
		linkTextView.backgroundColor = .enaColor(for: .background)
		linkTextView.isScrollEnabled = false
		linkTextView.isEditable = false
		linkTextView.textContainerInset = .zero
		linkTextView.textContainer.lineFragmentPadding = .zero
		linkTextView.textColor = .enaColor(for: .textPrimary1)
		linkTextView.tintColor = .enaColor(for: .textTint)

		return linkTextView
	}()

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		updateBorderWidth()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(contentStackView)

		contentStackView.addArrangedSubview(titleLabel)
		contentStackView.setCustomSpacing(0, after: titleLabel)
		contentStackView.addArrangedSubview(subtitleLabel)
		contentStackView.addArrangedSubview(descriptionLabel)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				contentStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				contentStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				contentStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				contentStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0)
			]
		)

//		accessibilityElements = [personalDataStackView as Any, preferredPersonSwitch as Any]
	}

	private func updateBorderWidth() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}
