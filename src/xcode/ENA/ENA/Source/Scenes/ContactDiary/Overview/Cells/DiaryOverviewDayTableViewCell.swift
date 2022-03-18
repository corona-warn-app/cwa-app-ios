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

		configureBackground()
	}

	// MARK: - Private

	private enum BorderOrientation {
		case left
		case top
		case right
		case bottom
	}

	@IBOutlet private weak var topBackground: UIView!
	@IBOutlet private weak var bottomBackground: UIView!

	// Header (the date)
	@IBOutlet private weak var dateStackView: UIStackView!
	@IBOutlet private weak var dateLabel: ENALabel!
	// ExposureHistory
	@IBOutlet private weak var exposureHistoryStackView: UIStackView!
	@IBOutlet private weak var exposureHistoryNoticeImageView: UIImageView!
	@IBOutlet private weak var exposureHistoryTitleLabel: ENALabel!
	@IBOutlet private weak var exposureHistoryDetailLabel: ENALabel!
	// PCR & Antigen Tests
	@IBOutlet private weak var testsStackView: UIStackView!
	// Check-Ins with risk
	@IBOutlet private weak var checkinHistoryContainerStackView: UIStackView!
	@IBOutlet private weak var checkinHistoryNoticeImageView: UIImageView!
	@IBOutlet private weak var checkinHistoryTitleLabel: ENALabel!
	@IBOutlet private weak var checkinHistoryDetailLabel: ENALabel!
	@IBOutlet private weak var checkinsWithRiskStackView: UIStackView!
	// Encounters
	@IBOutlet private weak var encountersVisitsContainerStackView: UIStackView!

	private var didTapClickableView: (() -> Void)?

	private func configureDateHeader(_ cellViewModel: DiaryOverviewDayCellModel) {
		dateLabel.text = cellViewModel.formattedDate
		dateLabel.accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.cellDateHeader, cellViewModel.accessibilityIdentifierIndex)

		let tapOnDateStackViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickableAreaWasTapped))
		dateStackView.addGestureRecognizer(tapOnDateStackViewRecognizer)
		drawBorders(to: [.left, .right], on: dateStackView)
		if #available(iOS 14.0, *) {
			dateStackView.backgroundColor = .enaColor(for: .cellBackground)
		} else {
			dateStackView.add(backgroundColor: .enaColor(for: .cellBackground))
		}
	}

	private func configureExposureHistory(_ cellViewModel: DiaryOverviewDayCellModel) {
		// Because we set the background color, the border of the underying view disappears. For this we need some new borders at the left and right.
		drawBorders(to: [.left, .right], on: exposureHistoryStackView)
		if #available(iOS 14.0, *) {
			exposureHistoryStackView.backgroundColor = .enaColor(for: .darkBackground)
		} else {
			exposureHistoryStackView.add(backgroundColor: .enaColor(for: .darkBackground))
		}

		exposureHistoryStackView.isHidden = cellViewModel.hideExposureHistory
		exposureHistoryNoticeImageView.image = cellViewModel.exposureHistoryImage
		exposureHistoryTitleLabel.text = cellViewModel.exposureHistoryTitle
		exposureHistoryTitleLabel.accessibilityIdentifier = cellViewModel.exposureHistoryAccessibilityIdentifier
		exposureHistoryDetailLabel.text = cellViewModel.exposureHistoryDetail
		exposureHistoryTitleLabel.style = .body
		exposureHistoryDetailLabel.style = .subheadline
		exposureHistoryDetailLabel.textColor = .enaColor(for: .textPrimary2)
	}

	private func configureTests(_ cellViewModel: DiaryOverviewDayCellModel) {
		// pcr & antigen tests
		testsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		if #available(iOS 14.0, *) {
			testsStackView.backgroundColor = .enaColor(for: .darkBackground)
		} else {
			testsStackView.add(backgroundColor: .enaColor(for: .darkBackground))
		}
		// Because we set the background color, the border of the underying view disappears. For this we need some new borders at the left and right and here for the top, too.
		drawBorders(to: [.left, .right], on: testsStackView)

		cellViewModel.diaryDayTests.forEach { diaryDayTest in

			let containerView = UIView()
			containerView.translatesAutoresizingMaskIntoConstraints = false

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
					imageView.widthAnchor.constraint(equalToConstant: 32),
					horizontalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18.0),
					horizontalStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12.0),
					horizontalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
					horizontalStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0)
				]
			)

			drawBorders(to: [.top], on: containerView)
			testsStackView.addArrangedSubview(containerView)
		}
		testsStackView.isHidden = cellViewModel.diaryDayTests.isEmpty
	}

	private func configureCheckinWithRisks(_ cellViewModel: DiaryOverviewDayCellModel) {
		// Check-Ins with risk
		checkinsWithRiskStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		checkinHistoryContainerStackView.isHidden = cellViewModel.hideCheckinRisk
		if #available(iOS 14.0, *) {
			checkinHistoryContainerStackView.backgroundColor = .enaColor(for: .darkBackground)
		} else {
			checkinHistoryContainerStackView.add(backgroundColor: .enaColor(for: .darkBackground))
		}
		// Because we set the background color, the border of the underlying view disappears. For this we need some new borders at the left and right.
		drawBorders(to: [.left, .right], on: checkinHistoryContainerStackView)

		checkinHistoryNoticeImageView.image = cellViewModel.checkinImage
		checkinHistoryTitleLabel.text = cellViewModel.checkinTitleHeadlineText
		checkinHistoryTitleLabel.accessibilityIdentifier = cellViewModel.checkinTitleAccessibilityIdentifier
		checkinHistoryTitleLabel.style = .body
		checkinHistoryDetailLabel.text = cellViewModel.checkinDetailDescription
		checkinHistoryDetailLabel.style = .subheadline
		checkinHistoryDetailLabel.textColor = .enaColor(for: .textPrimary2)

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
		encountersVisitsContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
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
			encountersVisitsContainerStackView.addArrangedSubview(entryStackView)

			// Let's draw a seperator line between each entryStackView.
			let separatorLine = UIView()
			separatorLine.backgroundColor = .enaColor(for: .hairline)
			separatorLine.translatesAutoresizingMaskIntoConstraints = false

			entryStackView.addSubview(separatorLine)

			let topConstraint: NSLayoutConstraint

			// Only for the first entryStackView we need the seperator line on the top of the container itself. Otherwise, we draw it on our own calculated position.
			if index == 0 {
				topConstraint = separatorLine.topAnchor.constraint(equalTo: encountersVisitsContainerStackView.topAnchor)
			} else {
				topConstraint = separatorLine.topAnchor.constraint(equalTo: entryStackView.topAnchor, constant: -10)
			}

			// Draw the seperator line from leading to trailing of the encountersVisitsContainerStackView
			NSLayoutConstraint.activate([
				separatorLine.heightAnchor.constraint(equalToConstant: 1),
				separatorLine.leadingAnchor.constraint(equalTo: encountersVisitsContainerStackView.leadingAnchor),
				separatorLine.trailingAnchor.constraint(equalTo: encountersVisitsContainerStackView.trailingAnchor),
				topConstraint
			])
		}
		encountersVisitsContainerStackView.isHidden = cellViewModel.selectedEntries.isEmpty
		let tapOnEncounterVisitsStackViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickableAreaWasTapped))
		encountersVisitsContainerStackView.addGestureRecognizer(tapOnEncounterVisitsStackViewRecognizer)

		drawBorders(to: [.left, .right], on: encountersVisitsContainerStackView)
		if #available(iOS 14.0, *) {
			encountersVisitsContainerStackView.backgroundColor = .enaColor(for: .cellBackground)
		} else {
			encountersVisitsContainerStackView.add(backgroundColor: .enaColor(for: .cellBackground))
		}

		encountersVisitsContainerStackView.spacing = 20
		encountersVisitsContainerStackView.distribution = .fill

		// For UI Testing
		accessibilityTraits = [.button]
		accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.cell, cellViewModel.accessibilityIdentifierIndex)
	}

	private func configureBackground() {

		topBackground.layer.cornerRadius = 14
		topBackground.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		if #available(iOS 13.0, *) {
			topBackground.layer.cornerCurve = .continuous
		}
		topBackground.layer.borderWidth = 1
		topBackground.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor

		topBackground.backgroundColor = .enaColor(for: .cellBackground)

		bottomBackground.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			bottomBackground.layer.cornerCurve = .continuous
		}
		bottomBackground.layer.borderWidth = 1
		bottomBackground.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		bottomBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

		// Show same background like the topBackground when we have not the encountersVisitsContainerStackView at the bottom displayed or the hole day is empty
		if (testsStackView.isHidden && exposureHistoryStackView.isHidden && checkinHistoryContainerStackView.isHidden) || !encountersVisitsContainerStackView.isHidden {
			bottomBackground.backgroundColor = .enaColor(for: .cellBackground)
		} else {
			bottomBackground.backgroundColor = .enaColor(for: .darkBackground)
		}
	}

	private func drawBorders(to orientations: [BorderOrientation], on view: UIView) {
		if view.subviews.contains(where: { view in
			guard let borderView = view as? StatefulView else {
				return false
			}
			return borderView.wasDrawn
		}) {
			// Skip drawing when the the borders were already drawn and the property was set to true
			return
		}

		orientations.forEach { orientation in

			let separator = StatefulView()
			separator.wasDrawn = true
			separator.backgroundColor = .enaColor(for: .hairline)
			separator.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(separator)

			switch orientation {

			case .left:
				NSLayoutConstraint.activate([
					separator.widthAnchor.constraint(equalToConstant: 1),
					separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
					separator.topAnchor.constraint(equalTo: view.topAnchor),
					separator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
				])
			case .top:
				NSLayoutConstraint.activate([
					separator.heightAnchor.constraint(equalToConstant: 1),
					separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
					separator.topAnchor.constraint(equalTo: view.topAnchor),
					separator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
				])
			case .right:
				NSLayoutConstraint.activate([
					separator.widthAnchor.constraint(equalToConstant: 1),
					separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
					separator.topAnchor.constraint(equalTo: view.topAnchor),
					separator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
				])
			case .bottom:
				NSLayoutConstraint.activate([
					separator.heightAnchor.constraint(equalToConstant: 1),
					separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
					separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
					separator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
				])
			}
		}
	}

	@objc
	private func clickableAreaWasTapped() {
		didTapClickableView?()
	}
}
