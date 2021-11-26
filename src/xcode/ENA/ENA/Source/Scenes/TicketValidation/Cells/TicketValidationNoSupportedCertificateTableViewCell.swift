//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TicketValidationNoSupportedCertificateCell: UITableViewCell, ReuseIdentifierProviding {

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

	func configure(_ cellModel: TicketValidationNoSupportedCertificateCellModel) {
		iconImageView.image = cellModel.iconImage
		serviceProviderRequirementsDescription.text = cellModel.serviceProviderRequirementsDescription

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

	private let serviceProviderRequirementsDescription: ENALabel = {
		let serviceProviderRequirementsDescription = ENALabel(style: .body)
		serviceProviderRequirementsDescription.translatesAutoresizingMaskIntoConstraints = false
		serviceProviderRequirementsDescription.numberOfLines = 0
		serviceProviderRequirementsDescription.textColor = .enaColor(for: .textPrimary1)

		return serviceProviderRequirementsDescription
	}()

	private var cellModel: TicketValidationNoSupportedCertificateCellModel?

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
		backgroundContainerView.addSubview(serviceProviderRequirementsDescription)

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

				serviceProviderRequirementsDescription.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12.0),
				serviceProviderRequirementsDescription.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: -4.0),
				serviceProviderRequirementsDescription.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),
				serviceProviderRequirementsDescription.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0)
			]
		)
	}

	private func updateBorderColor() {
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
	}
}
