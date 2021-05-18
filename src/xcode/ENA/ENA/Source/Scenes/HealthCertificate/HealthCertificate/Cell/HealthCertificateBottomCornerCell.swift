////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateBottomCornerCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		accessoryType = .none
		accessibilityHint = .none
		isAccessibilityElement = false
		accessibilityElementsHidden = true
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Private

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .darkBackground)
		tileView.layer.cornerRadius = 12.0
		tileView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		if #available(iOS 13.0, *) {
			tileView.layer.cornerCurve = .continuous
		}
		contentView.addSubview(tileView)

		NSLayoutConstraint.activate([
			tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
			tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20.0)
		])
	}

}
