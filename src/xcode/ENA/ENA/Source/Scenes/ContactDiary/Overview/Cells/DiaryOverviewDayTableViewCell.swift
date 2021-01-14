////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryOverviewDayTableViewCell: UITableViewCell {

	// MARK: - Override

	override func awakeFromNib() {
		super.awakeFromNib()

		exposureHistoryStackView.isHidden = false
	}

	// MARK: - Internal

	func configure(day: DiaryDay) {
		dateLabel.text = day.formattedDate

		encountersVisitsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for entry in day.selectedEntries {
			let imageView = UIImageView()
			NSLayoutConstraint.activate([
				imageView.widthAnchor.constraint(equalToConstant: 32),
				imageView.heightAnchor.constraint(equalToConstant: 32)
			])

			let label = ENALabel()

			let entryStackView = UIStackView()
			entryStackView.axis = .horizontal
			entryStackView.spacing = 15
			entryStackView.alignment = .center

			entryStackView.addArrangedSubview(imageView)
			entryStackView.addArrangedSubview(label)

			switch entry {
			case .contactPerson(let contactPerson):
				imageView.image = UIImage(named: "Icons_Diary_ContactPerson")
				label.text = contactPerson.name
			case .location(let location):
				imageView.image = UIImage(named: "Icons_Diary_Location")
				label.text = location.name
			}

			encountersVisitsStackView.addArrangedSubview(entryStackView)
		}

		encountersVisitsContainerStackView.isHidden = encountersVisitsStackView.arrangedSubviews.isEmpty

		accessibilityTraits = [.button]
	}

	// MARK: - Private

	@IBOutlet private weak var dateLabel: ENALabel!
	@IBOutlet private weak var encountersVisitsContainerStackView: UIStackView!
	@IBOutlet private weak var encountersVisitsStackView: UIStackView!
	@IBOutlet private weak var exposureHistoryStackView: UIStackView!
	@IBOutlet private weak var exposureHistoryNoticeImageView: UIImageView!
	@IBOutlet private weak var exposureHistoryTitleLabel: ENALabel!
	@IBOutlet private weak var exposureHistoryDetailLabel: ENALabel!

}
