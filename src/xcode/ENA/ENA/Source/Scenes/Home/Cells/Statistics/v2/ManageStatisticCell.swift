//
// 🦠 Corona-Warn-App
//

import UIKit

class ManageStatisticCell: UICollectionViewCell {

	typealias AddElementHandler = () -> Void
	typealias ModifyElementHandler = () -> Void

	static let reuseIdentifier = "ManageStatisticCell"

	@IBOutlet weak var stackView: UIStackView!

	var handleAdd: AddElementHandler?
	var handleModify: ModifyElementHandler?

    override func awakeFromNib() {
        super.awakeFromNib()

		// TODO: states: just add vs. add + modify vs. modify
		let tap1 = UITapGestureRecognizer(target: self, action: #selector(onTap))
		tap1.cancelsTouchesInView = false
		addView.backgroundColor = .green.withAlphaComponent(0.2)
		addView.addGestureRecognizer(tap1)
		stackView.addArrangedSubview(addView)

		let tap2 = UITapGestureRecognizer(target: self, action: #selector(onTap))
		tap2.cancelsTouchesInView = false
		modifyView.backgroundColor = .yellow.withAlphaComponent(0.2)
		modifyView.addGestureRecognizer(tap2)
		stackView.addArrangedSubview(modifyView)
    }

	// MARK: - Private

	private let addView = CustomDashedView()
	private let modifyView = CustomDashedView()

	@objc
	private func onTap(_ sender: UIGestureRecognizer) {
		switch sender.view {
		case addView:
			Log.debug("add cell tapped", log: .ui)
			handleAdd?()
		case modifyView:
			Log.debug("modify cell tapped", log: .ui)
			handleModify?()
		default:
			break
		}
	}
}
