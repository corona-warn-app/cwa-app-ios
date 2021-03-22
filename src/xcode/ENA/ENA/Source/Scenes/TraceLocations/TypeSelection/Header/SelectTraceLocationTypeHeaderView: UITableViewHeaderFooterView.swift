////
// 🦠 Corona-Warn-App
//

import UIKit

class SelectTraceLocationTypeHeaderView: UITableViewHeaderFooterView, ReuseIdentifierProviding {

	// MARK: - Init
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(_ model: String) {
		titleLabel.text = model
	}

	// MARK: - Private

	private let titleLabel = ENALabel()

	private func setupView() {
		contentView.backgroundColor = .enaColor(for: .background)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleLabel)
		titleLabel.font = .enaFont(for: .footnote)
		titleLabel.textColor = .enaColor(for: .textSemanticGray)
		titleLabel.accessibilityTraits = .header

		let separatorView = UIView()
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		separatorView.backgroundColor = .enaColor(for: .hairline)
		contentView.addSubview(separatorView)

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22.0),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7.0),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23.0),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17.0),
			separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			separatorView.heightAnchor.constraint(equalToConstant: 1.0)
		])
	}
}
