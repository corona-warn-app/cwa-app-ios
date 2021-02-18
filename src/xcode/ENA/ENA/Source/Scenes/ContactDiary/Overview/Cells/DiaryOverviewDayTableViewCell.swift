////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryOverviewDayTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellViewModel: DiaryOverviewDayCellModel) {
		dateLabel.text = cellViewModel.formattedDate

		exposureHistoryStackView.isHidden = cellViewModel.hideExposureHistory
		exposureHistoryNoticeImageView.image = cellViewModel.exposureHistoryImage
		exposureHistoryTitleLabel.text = cellViewModel.exposureHistoryTitle
		exposureHistoryTitleLabel.accessibilityIdentifier = cellViewModel.exposureHistoryAccessibilityIdentifier
		exposureHistoryDetailLabel.text = cellViewModel.exposureHistoryDetail
		exposureHistoryTitleLabel.style = .body
		exposureHistoryDetailLabel.style = .subheadline
		exposureHistoryDetailLabel.textColor = .enaColor(for: .textPrimary2)

		encountersVisitsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for entry in cellViewModel.selectedEntries {
			let imageView = UIImageView()
			NSLayoutConstraint.activate([
				imageView.widthAnchor.constraint(equalToConstant: 32),
				imageView.heightAnchor.constraint(equalToConstant: 32)
			])

			let entryLabel = ENALabel()
			entryLabel.adjustsFontForContentSizeCategory = true
			entryLabel.style = .body

			let entryDetailLabel = ENALabel()
			entryDetailLabel.adjustsFontForContentSizeCategory = true
			entryDetailLabel.numberOfLines = 0
			entryDetailLabel.style = .body
			entryDetailLabel.textColor = .enaColor(for: .textPrimary2)

			let entryCircumstancesLabel = ENALabel()
			entryCircumstancesLabel.adjustsFontForContentSizeCategory = true
			entryCircumstancesLabel.numberOfLines = 0
			entryCircumstancesLabel.font = .enaFont(for: .body, italic: true)
			entryCircumstancesLabel.textColor = .enaColor(for: .textPrimary2)

			let entryLabelStackView = UIStackView()
			entryLabelStackView.translatesAutoresizingMaskIntoConstraints = false
			entryLabelStackView.axis = .vertical

			entryLabelStackView.addArrangedSubview(entryLabel)

			switch entry {
			case .contactPerson(let contactPerson):
				imageView.image = UIImage(named: "Icons_Diary_ContactPerson")
				entryLabel.text = contactPerson.name


				let detailLabelText = cellViewModel.ent
				entryDetailLabel.text = "some person detail text, some person detail text, some person detail text"
				entryLabelStackView.addArrangedSubview(entryDetailLabel)

				entryCircumstancesLabel.text = "some circumstances lalala"
				entryLabelStackView.addArrangedSubview(entryCircumstancesLabel)
			case .location(let location):
				imageView.image = UIImage(named: "Icons_Diary_Location")
				entryLabel.text = location.name
				entryDetailLabel.text = "some location detail text"
				entryCircumstancesLabel.text = "some circumstances lalala"
			}

			let entryStackView = UIStackView()
			entryStackView.axis = .horizontal
			entryStackView.spacing = 15
			entryStackView.alignment = .center

			entryStackView.addArrangedSubview(imageView)
			entryStackView.addArrangedSubview(entryLabelStackView)

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
