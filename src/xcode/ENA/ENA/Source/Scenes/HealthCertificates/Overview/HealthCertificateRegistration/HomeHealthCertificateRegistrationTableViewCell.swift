////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeHealthCertificateRegistrationTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		
		setup()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setup()
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		
		cardView.setHighlighted(highlighted, animated: animated)
	}
	
	// MARK: - Internal
	
	func configure(with cellModel: HomeHealthCertificateRegistrationCellModel) {
		titleLabel.text = cellModel.title
		descriptionLabel.text = cellModel.description

		accessibilityIdentifier = cellModel.accessibilityIdentifier
	}
	
	// MARK: - Private
	
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var cardView: CardView!
	
	private var onPrimaryAction: (() -> Void)?
	
	private func setup() {
		clipsToBounds = false

		cardView.accessibilityElements = [titleLabel as Any, descriptionLabel as Any]
		titleLabel.accessibilityTraits = [.header, .button]
	}
	
}
