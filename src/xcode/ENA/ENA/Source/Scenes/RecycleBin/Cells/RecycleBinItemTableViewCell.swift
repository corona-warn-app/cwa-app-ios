////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class RecycleBinItemTableViewCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		containerView.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			containerView.layer.cornerCurve = .continuous
		}

		accessibilityTraits = [.button]
		accessibilityIdentifier = AccessibilityIdentifiers.RecycleBin.itemCell

		setCellBackgroundColor()
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		if highlighted {
			containerView.backgroundColor = .enaColor(for: .listHighlight)
		} else {
			containerView.backgroundColor = cellBackgroundColor
		}
	}

	// MARK: - Internal

	func configure(cellModel: RecycleBinItemCellModel) {
		iconImageView.image = cellModel.iconImage

		titleLabel.text = cellModel.title

		nameLabel.text = cellModel.name
		nameLabel.isHidden = cellModel.name == nil

		secondaryLabel.text = cellModel.secondaryInfo
		secondaryLabel.isHidden = cellModel.secondaryInfo == nil

		tertiaryLabel.text = cellModel.tertiaryInfo
		tertiaryLabel.isHidden = cellModel.tertiaryInfo == nil
        
        quaternaryLabel.text = cellModel.quaternaryInfo
        quaternaryLabel.isHidden = cellModel.quaternaryInfo == nil
        spacer.isHidden = cellModel.quaternaryInfo == nil
	}

	// MARK: - Private

	@IBOutlet private weak var containerView: UIView!
	@IBOutlet private weak var iconImageView: UIImageView!

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var nameLabel: ENALabel!
	@IBOutlet private weak var secondaryLabel: ENALabel!
	@IBOutlet private weak var tertiaryLabel: ENALabel!
	@IBOutlet private weak var quaternaryLabel: ENALabel!
	@IBOutlet private weak var spacer: UIView!
    
	private var cellBackgroundColor: UIColor = .enaColor(for: .cellBackground)

	private func setCellBackgroundColor() {
		if #available(iOS 13.0, *) {
			if traitCollection.userInterfaceLevel == .elevated {
				cellBackgroundColor = .enaColor(for: .cellBackground3)
			} else {
				cellBackgroundColor = .enaColor(for: .cellBackground)
			}
		}

		containerView.backgroundColor = cellBackgroundColor
	}

}
