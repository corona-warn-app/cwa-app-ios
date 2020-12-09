////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryOverviewDayTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(day: DiaryDay) {
		dateLabel.text = day.formattedDate

		encountersVisitsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for entry in day.entries {
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
			case .contactPerson(let contactPerson) where contactPerson.encounterId != nil:
				imageView.image = UIImage(named: "Icons_Diary_ContactPerson")
				label.text = contactPerson.name
			case .location(let location) where location.visitId != nil:
				imageView.image = UIImage(named: "Icons_Diary_Location")
				label.text = location.name
			default:
				continue
			}

			encountersVisitsStackView.addArrangedSubview(entryStackView)
		}

		encountersVisitsContainerStackView.isHidden = encountersVisitsStackView.arrangedSubviews.isEmpty
	}

	// MARK: - Private

	@IBOutlet private weak var dateLabel: ENALabel!
	@IBOutlet private weak var encountersVisitsContainerStackView: UIStackView!
	@IBOutlet private weak var encountersVisitsStackView: UIStackView!

}
