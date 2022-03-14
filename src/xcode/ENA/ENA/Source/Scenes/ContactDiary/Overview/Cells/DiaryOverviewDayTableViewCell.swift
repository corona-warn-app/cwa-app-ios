////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryOverviewDayTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(
		cellViewModel: DiaryOverviewDayCellModel,
		didTapClickableView: @escaping () -> Void
	) {
		self.didTapClickableView = didTapClickableView

		// should be clickable with grey background
		configureDateHeader(cellViewModel)
		// should not be clickable with white background
		configureExposureHistory(cellViewModel)
		// should not be clickable with white background
		configureTests(cellViewModel)
		// should not be clickable with white background
		configureCheckinWithRisks(cellViewModel)
		// should be clickable with grey background
		configureEncounters(cellViewModel)

		cellContainerView.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			cellContainerView.layer.cornerCurve = .continuous
		}
		cellContainerView.layer.borderWidth = 1
		cellContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor

	}

	// MARK: - Private

	@IBOutlet private weak var cellContainerView: UIView!
	@IBOutlet private weak var dateStackView: UIStackView!
	@IBOutlet private weak var dateLabel: ENALabel!
	@IBOutlet private weak var encountersVisitsContainerStackView: UIStackView!
	@IBOutlet private weak var encountersVisitsStackView: UIStackView!
	@IBOutlet private weak var exposureHistoryStackView: UIStackView!
	@IBOutlet private weak var exposureHistoryNoticeImageView: UIImageView!
	@IBOutlet private weak var exposureHistoryTitleLabel: ENALabel!
	@IBOutlet private weak var exposureHistoryDetailLabel: ENALabel!

	// PCR & Antigen TestsStackView
	@IBOutlet private weak var testsStackView: UIStackView!

	// Check-Ins with risk
	@IBOutlet private weak var checkinHistoryStackView: UIStackView!
	@IBOutlet private weak var checkinHistoryNoticeImageView: UIImageView!
	@IBOutlet private weak var checkinHistoryTitleLabel: ENALabel!
	@IBOutlet private weak var checkinHistoryDetailLabel: ENALabel!
	@IBOutlet private weak var checkinsWithRiskStackView: UIStackView!

	private var didTapClickableView: (() -> Void)?

	private func configureDateHeader(_ cellViewModel: DiaryOverviewDayCellModel) {
		dateLabel.text = cellViewModel.formattedDate
		dateLabel.accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.cellDateHeader, cellViewModel.accessibilityIdentifierIndex)

		let tapOnDateStackViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickableAreaWasTapped))
		dateStackView.addGestureRecognizer(tapOnDateStackViewRecognizer)
	}

	private func configureExposureHistory(_ cellViewModel: DiaryOverviewDayCellModel) {
		exposureHistoryStackView.isHidden = cellViewModel.hideExposureHistory
		exposureHistoryNoticeImageView.image = cellViewModel.exposureHistoryImage
		exposureHistoryTitleLabel.text = cellViewModel.exposureHistoryTitle
		exposureHistoryTitleLabel.accessibilityIdentifier = cellViewModel.exposureHistoryAccessibilityIdentifier
		exposureHistoryDetailLabel.text = cellViewModel.exposureHistoryDetail
		exposureHistoryTitleLabel.style = .body
		exposureHistoryDetailLabel.style = .subheadline
		exposureHistoryDetailLabel.textColor = .enaColor(for: .textPrimary2)

		exposureHistoryStackView.backgroundColor = .enaColor(for: .background)
	}

	private func configureTests(_ cellViewModel: DiaryOverviewDayCellModel) {
		// pcr & antigen tests
		testsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		cellViewModel.diaryDayTests.forEach { diaryDayTest in

			let containerView = UIView()
			containerView.translatesAutoresizingMaskIntoConstraints = false

			let separator = UIView()
			separator.translatesAutoresizingMaskIntoConstraints = false
			separator.backgroundColor = .enaColor(for: .hairline)
			containerView.addSubview(separator)

			let imageView = UIImageView()
			imageView.translatesAutoresizingMaskIntoConstraints = false
			imageView.contentMode = .center
			imageView.image = diaryDayTest.result == .negative ? UIImage(imageLiteralResourceName: "Test_green") : UIImage(imageLiteralResourceName: "Test_red")

			let titleLabel = ENALabel()
			titleLabel.style = .body
			titleLabel.text = diaryDayTest.type == .pcr ? AppStrings.ContactDiary.Overview.Tests.pcrRegistered : AppStrings.ContactDiary.Overview.Tests.antigenDone

			let detailLabel = ENALabel()
			detailLabel.style = .subheadline
			detailLabel.textColor = .enaColor(for: .textPrimary2)
			detailLabel.text = diaryDayTest.result == .negative ? AppStrings.ContactDiary.Overview.Tests.negativeResult : AppStrings.ContactDiary.Overview.Tests.positiveResult

			let verticalStackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
			verticalStackView.axis = .vertical
			verticalStackView.spacing = 8.0

			let horizontalStackView = UIStackView(arrangedSubviews: [imageView, verticalStackView])
			horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
			horizontalStackView.alignment = .center
			horizontalStackView.spacing = 15.0
			containerView.addSubview(horizontalStackView)

			NSLayoutConstraint.activate(
				[
					separator.heightAnchor.constraint(equalToConstant: 1.0),
					separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
					separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

					imageView.widthAnchor.constraint(equalToConstant: 32),
					horizontalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18.0),
					horizontalStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12.0),
					horizontalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
					horizontalStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0)
				]
			)

			testsStackView.addArrangedSubview(containerView)
		}
		testsStackView.backgroundColor = .enaColor(for: .background)
	}

	private func configureCheckinWithRisks(_ cellViewModel: DiaryOverviewDayCellModel) {
		// Check-Ins with risk
		checkinHistoryStackView.isHidden = cellViewModel.hideCheckinRisk
		checkinHistoryStackView.backgroundColor = .enaColor(for: .background)
		checkinHistoryNoticeImageView.image = cellViewModel.checkinImage
		checkinHistoryTitleLabel.text = cellViewModel.checkinTitleHeadlineText
		checkinHistoryTitleLabel.accessibilityIdentifier = cellViewModel.checkinTitleAccessibilityIdentifier
		checkinHistoryTitleLabel.style = .body
		checkinHistoryDetailLabel.text = cellViewModel.checkinDetailDescription
		checkinHistoryDetailLabel.style = .subheadline
		checkinHistoryDetailLabel.textColor = .enaColor(for: .textPrimary2)

		checkinsWithRiskStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		cellViewModel.checkinsWithRisk.enumerated().forEach { index, riskyCheckin in
			let checkInLabel = ENALabel()
			checkInLabel.adjustsFontForContentSizeCategory = true
			checkInLabel.numberOfLines = 0
			checkInLabel.style = .subheadline
			checkInLabel.textColor = .enaColor(for: .textPrimary2)
			let riskColor = cellViewModel.colorFor(riskLevel: riskyCheckin.risk)
			let eventName = cellViewModel.checkInDespription(checkinWithRisk: riskyCheckin)
			let checkinName = NSAttributedString(string: eventName).bulletPointString(bulletPointFont: .enaFont(for: .title2, weight: .bold, italic: false), bulletPointColor: riskColor)

			checkInLabel.attributedText = checkinName
			checkInLabel.isAccessibilityElement = true
			checkInLabel.accessibilityIdentifier = "CheckinWithRisk\(index)"
			checkinsWithRiskStackView.addArrangedSubview(checkInLabel)
		}
	}

	private func configureEncounters(_ cellViewModel: DiaryOverviewDayCellModel) {
		encountersVisitsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		cellViewModel.selectedEntries.enumerated().forEach { index, entry in
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
				entryLabel.accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.person, index)

				if let personEncounter = contactPerson.encounter {
					let detailLabelText = cellViewModel.entryDetailTextFor(personEncounter: personEncounter)
					if detailLabelText != "" {
						entryDetailLabel.text = detailLabelText
						entryLabelStackView.addArrangedSubview(entryDetailLabel)
					}

					if personEncounter.circumstances != "" {
						entryCircumstancesLabel.text = personEncounter.circumstances
						entryLabelStackView.addArrangedSubview(entryCircumstancesLabel)
					}
				}

			case .location(let location):
				imageView.image = UIImage(named: "Icons_Diary_Location")
				entryLabel.text = location.name
				entryLabel.accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.location, index)

				if let locationVisit = location.visit {
					let detailLabelText = cellViewModel.entryDetailTextFor(locationVisit: locationVisit)

					if detailLabelText != "" {
						entryDetailLabel.text = detailLabelText
						entryLabelStackView.addArrangedSubview(entryDetailLabel)
					}

					if locationVisit.circumstances != "" {
						entryCircumstancesLabel.text = locationVisit.circumstances
						entryLabelStackView.addArrangedSubview(entryCircumstancesLabel)
					}
				}
			}

			let entryStackView = UIStackView()
			entryStackView.axis = .horizontal
			entryStackView.spacing = 15
			entryStackView.alignment = .center

			entryStackView.addArrangedSubview(imageView)
			entryStackView.addArrangedSubview(entryLabelStackView)

			encountersVisitsStackView.addArrangedSubview(entryStackView)
			let entryHeight = CGFloat(30) + imageView.frame.height
			encountersVisitsStackView.spacing = entryHeight

			let separatorLine = UIView()
			separatorLine.backgroundColor = .enaColor(for: .hairline)
			separatorLine.translatesAutoresizingMaskIntoConstraints = false

			entryStackView.addSubview(separatorLine)

			// Draw a seperator line from leading to trailing of the cellContainerView and between two entryStackViews. For this we need some offsets.
			NSLayoutConstraint.activate([
				separatorLine.heightAnchor.constraint(equalToConstant: 1),
				separatorLine.topAnchor.constraint(equalTo: entryStackView.centerYAnchor, constant: -(entryHeight)),
				separatorLine.leadingAnchor.constraint(equalTo: encountersVisitsStackView.leadingAnchor),
				separatorLine.trailingAnchor.constraint(equalTo: encountersVisitsStackView.trailingAnchor)
			])
		}

		encountersVisitsContainerStackView.isHidden = encountersVisitsStackView.arrangedSubviews.isEmpty
		let tapOnEncounterVisitsStackViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickableAreaWasTapped))
		encountersVisitsContainerStackView.addGestureRecognizer(tapOnEncounterVisitsStackViewRecognizer)

		accessibilityTraits = [.button]
		accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.cell, cellViewModel.accessibilityIdentifierIndex)

	}

	@objc
	private func clickableAreaWasTapped() {
		didTapClickableView?()
	}

}
