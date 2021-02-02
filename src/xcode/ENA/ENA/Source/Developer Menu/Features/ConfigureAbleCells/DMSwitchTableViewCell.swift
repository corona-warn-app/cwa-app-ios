//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

protocol ConfigureAbleCell {
	func configure<T>(cellViewModel: T)
}

class DMSwitchTableViewCell: UITableViewCell, ConfigureAbleCell {

	// MARK: - Init

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		infoLabel.font = .enaFont(for: .subheadline)
		toggleSwitch.addTarget(self, action: #selector(toggleHit), for: .valueChanged)
	}

	// MARK: - Public

	// MARK: - Internal

	func configure<T>(cellViewModel: T) {
		guard let cellViewModel = cellViewModel as? DMSwitchCellViewModel else {
			Log.debug("can't configure cell")
			return
		}
		infoLabel.text = cellViewModel.labelText
		toggleSwitch.isOn = cellViewModel.isOn()
		self.cellViewModel = cellViewModel
	}

	// MARK: - Private

	@IBOutlet private weak var infoLabel: UILabel!
	@IBOutlet private weak var toggleSwitch: UISwitch!

	private var cellViewModel: DMSwitchCellViewModel?

	@objc
	private func toggleHit() {
		cellViewModel?.toggle()
		setSelected(false, animated: true)
	}

}

#endif
