////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class MissingPermissionsTableViewCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(cellModel: MissingPermissionsCellModel, onButtonTap: @escaping () -> Void) {
		cellModel.textColorPublisher
			.assign(to: \.textColor, on: titleLabel)
			.store(in: &subscriptions)

		cellModel.textColorPublisher
			.assign(to: \.textColor, on: descriptionLabel)
			.store(in: &subscriptions)

		cellModel.isButtonEnabledPublisher
			.assign(to: \.isEnabled, on: button)
			.store(in: &subscriptions)

		// Retaining cell model so it gets updated
		self.cellModel = cellModel
		self.onButtonTap = onButtonTap
	}

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: MissingPermissionsCellModel?
	private var onButtonTap: (() -> Void)?

	let titleLabel = ENALabel()
	let descriptionLabel = ENALabel()
	let button = ENAButton()

	private func setupView() {
		let qrCodeImageView = UIImageView(image: UIImage(imageLiteralResourceName: "Icons_iOS_Einstellungen"))
		qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeImageView.contentMode = .right

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = .enaFont(for: .title2)
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.textAlignment = .left
		titleLabel.numberOfLines = 0
		titleLabel.text = AppStrings.Checkins.Overview.MissingPermissions.title

		let hStackView = UIStackView(arrangedSubviews: [titleLabel, qrCodeImageView])
		hStackView.translatesAutoresizingMaskIntoConstraints = false
		hStackView.axis = .horizontal
		hStackView.alignment = .center
		hStackView.distribution = .fill
		hStackView.spacing = 4.0

		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.font = .enaFont(for: .body)
		descriptionLabel.textColor = .enaColor(for: .textPrimary1)
		descriptionLabel.textAlignment = .left
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = AppStrings.Checkins.Overview.MissingPermissions.description

		button.setTitle(AppStrings.Checkins.Overview.MissingPermissions.buttonTitle, for: .normal)
		button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

		let vStackView = UIStackView(arrangedSubviews: [hStackView, descriptionLabel, button])
		vStackView.translatesAutoresizingMaskIntoConstraints = false
		vStackView.axis = .vertical
		vStackView.distribution = .fill
		vStackView.spacing = 14.0

		let backgroundView = UIView(frame: .zero)
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.backgroundColor = .enaColor(for: .cellBackground)
		backgroundView.layer.cornerRadius = 14.0

		if #available(iOS 13.0, *) {
			backgroundView.layer.cornerCurve = .continuous
		}

		contentView.addSubview(backgroundView)
		backgroundView.addSubview(vStackView)

		NSLayoutConstraint.activate(
			[
				qrCodeImageView.widthAnchor.constraint(equalToConstant: 28.0),
				backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0),
				backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0),
				backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
				backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

				vStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16.0),
				vStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16.0),
				vStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 14.0),
				vStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -14.0)
			]
		)
	}


	@objc
	private func didTapButton() {
		onButtonTap?()
	}

}
