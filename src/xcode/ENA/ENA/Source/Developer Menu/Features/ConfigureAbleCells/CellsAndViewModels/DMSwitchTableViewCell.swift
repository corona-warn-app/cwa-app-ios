//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMSwitchTableViewCell: UITableViewCell, ConfigureableCell {

	// loading without a xib
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		layoutViews()
	}

	// loading from xib
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		infoLabel.font = .enaFont(for: .subheadline)
		toggleSwitch.addTarget(self, action: #selector(toggleHit), for: .valueChanged)
	}

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

	private func layoutViews() {
		let infoLabel = UILabel()
		infoLabel.translatesAutoresizingMaskIntoConstraints = false
		self.infoLabel = infoLabel

		let toggleSwitch = UISwitch()
		toggleSwitch.addTarget(self, action: #selector(toggleHit), for: .valueChanged)
		toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
		self.toggleSwitch = toggleSwitch

		let stackView = UIStackView(arrangedSubviews: [infoLabel, toggleSwitch])
		stackView.axis = .horizontal
		stackView.distribution = .fillProportionally
		stackView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(stackView)

		NSLayoutConstraint.activate(
			[
				stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
				stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
				stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0)
			]
		)
	}

}

#endif
