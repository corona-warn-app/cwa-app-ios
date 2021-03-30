////
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationDetailsQRCodeCell: UITableViewCell, ReuseIdentifierProviding {

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

	func configure(_ qrCode: UIImage) {
		qrCodeView.image = qrCode
	}

	// MARK: - Private

	private let qrCodeView = UIImageView()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		let tileView = UIView()
		tileView.backgroundColor = .enaColor(for: .background)
		if #available(iOS 13.0, *) {
			tileView.layer.cornerCurve = .continuous
		}
		tileView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(tileView)
		
		qrCodeView.translatesAutoresizingMaskIntoConstraints = false
		tileView.addSubview(qrCodeView)
		
		NSLayoutConstraint.activate([
			tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
			tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32.0),
			tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32.0),

			qrCodeView.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 2.0),
			qrCodeView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -2.0),
			qrCodeView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 5.0),
			qrCodeView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -5.0)
		])
	}
}
