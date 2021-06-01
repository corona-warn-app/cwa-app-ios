////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TestCertificateInfoTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		
		setup()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setup()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		cardView.setNeedsLayout()
		cardView.layoutIfNeeded()
		borderLayer.path = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 14).cgPath
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		setBorderColor()
	}
	
	// MARK: - Internal
	
	func configure(with cellModel: TestCertificateInfoCellModel) {
		titleLabel.text = cellModel.title
		descriptionLabel.text = cellModel.description

		accessibilityIdentifier = cellModel.accessibilityIdentifier
	}
	
	// MARK: - Private
	
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var cardView: UIView!

	private let borderLayer = CAShapeLayer()
	
	private var onPrimaryAction: (() -> Void)?
	
	private func setup() {
		cardView.backgroundColor = .enaColor(for: .backgroundLightGray)
		cardView.layer.cornerRadius = 14

		setBorderColor()
		borderLayer.lineDashPattern = [5, 8]
		borderLayer.frame = bounds
		borderLayer.fillColor = nil
		borderLayer.lineWidth = 2

		cardView.layer.addSublayer(borderLayer)

		cardView.accessibilityElements = [titleLabel as Any, descriptionLabel as Any]
		titleLabel.accessibilityTraits = [.header, .button]
	}

	private func setBorderColor() {
		borderLayer.strokeColor = UIColor.enaColor(for: .dashedCardBorder).cgColor
	}
	
}
