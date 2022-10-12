//
// 🦠 Corona-Warn-App
//

import UIKit

class SelectTraceLocationTypeCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(cellModel: TraceLocationType) {
		titleLabel.text = cellModel.title
		subtitleLabel.text = cellModel.subtitle
		accessibilityIdentifier = cellModel.accessibilityIdentifier
		subtitleLabel.isHidden = cellModel.subtitle == nil
	}

	// MARK: - Private

	private let titleLabel = ENALabel()
	private let subtitleLabel = ENALabel()

	private func setupView() {
		backgroundColor = .enaColor(for: .background)

		accessibilityTraits = .button
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = .enaFont(for: .body)
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.numberOfLines = 0

		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		subtitleLabel.font = .enaFont(for: .subheadline)
		subtitleLabel.textColor = .enaColor(for: .textSemanticGray)
		subtitleLabel.numberOfLines = 0

		let stackView = UIStackView(arrangedSubviews: [
			titleLabel,
			subtitleLabel
		])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 4.0
		contentView.addSubview(stackView)

		let separatorView = UIView()
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		separatorView.backgroundColor = .enaColor(for: .hairline)
		contentView.addSubview(separatorView)

		NSLayoutConstraint.activate([
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52.0),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23.0),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17.0),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0),
			separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23.0),
			separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17.0),
			separatorView.heightAnchor.constraint(equalToConstant: 1.0)

		])
	}

}
