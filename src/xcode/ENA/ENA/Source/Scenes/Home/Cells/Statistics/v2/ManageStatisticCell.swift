//
// 🦠 Corona-Warn-App
//

import UIKit

class ManageStatisticCell: UICollectionViewCell {

	static let reuseIdentifier = "ManageStatisticCell"

	@IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

		// dummy!
		stackView.addArrangedSubview(managementView())
		stackView.addArrangedSubview(managementView())
    }
	
	private func managementView() -> UIView {
		let view = UIView()
		view.layer.masksToBounds = true

		view.backgroundColor = .enaColor(for: .backgroundLightGray)
		
		view.layer.borderWidth = 2
		view.layer.cornerRadius = 10
		view.layer.borderColor = UIColor.darkGray.cgColor
		return view
	}
}
