//
// 🦠 Corona-Warn-App
//

import UIKit
import Contacts
import OpenCombine

final class OnBehalfDateTimeSelectionViewModel {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		onPrimaryButtonTap: @escaping (Checkin) -> Void
	) {
		self.traceLocation = traceLocation
		self.onPrimaryButtonTap = onPrimaryButtonTap
	}

	// MARK: - Internal

	func createCheckin() {
		let checkin: Checkin = Checkin(
			id: 0,
			traceLocationId: traceLocation.id,
			traceLocationIdHash: traceLocation.idHash ?? Data(),
			traceLocationVersion: traceLocation.version,
			traceLocationType: traceLocation.type,
			traceLocationDescription: traceLocation.description,
			traceLocationAddress: traceLocation.address,
			traceLocationStartDate: traceLocation.startDate,
			traceLocationEndDate: traceLocation.endDate,
			traceLocationDefaultCheckInLengthInMinutes: traceLocation.defaultCheckInLengthInMinutes,
			cryptographicSeed: traceLocation.cryptographicSeed,
			cnPublicKey: traceLocation.cnPublicKey,
			checkinStartDate: selectedDate,
			checkinEndDate: selectedDate.addingTimeInterval(selectedDuration),
			checkinCompleted: false,
			createJournalEntry: false,
			checkinSubmitted: false
		)

		onPrimaryButtonTap(checkin)
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.space(height: 8),
					.body(
						text: AppStrings.HealthCertificate.Validation.body1,
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.headline(
						text: AppStrings.HealthCertificate.Validation.headline1,
						accessibilityIdentifier: ""
					),
					durationSelectionCell(),
					.space(height: 8),
					dateSelectionCell(),
					.space(height: 8),
					.body(
						text: AppStrings.HealthCertificate.Validation.body2,
						accessibilityIdentifier: ""
					),
					.headline(
						text: AppStrings.HealthCertificate.Validation.headline2,
						accessibilityIdentifier: ""
					),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.bullet1, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.bullet2, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.bullet3, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.bullet4, spacing: .large),
					.textWithLinks(
						text: String(
							format: AppStrings.HealthCertificate.Validation.moreInformation,
							AppStrings.HealthCertificate.Validation.moreInformationPlaceholderFAQ, AppStrings.Links.healthCertificateValidationEU),
						links: [
							AppStrings.HealthCertificate.Validation.moreInformationPlaceholderFAQ: AppStrings.Links.healthCertificateValidationFAQ,
							AppStrings.Links.healthCertificateValidationEU: AppStrings.Links.healthCertificateValidationEU
						],
						linksColor: .enaColor(for: .textTint)
					),
					.legal(title: NSAttributedString(string: AppStrings.HealthCertificate.Validation.legalTitle), description: NSAttributedString(string: AppStrings.HealthCertificate.Validation.legalDescription), textBlocks: []),
					.space(height: 16)
			])
		])
	}

	// MARK: - Private

	private let traceLocation: TraceLocation
	private let onPrimaryButtonTap: (Checkin) -> Void

	private var selectedDate: Date = Date()
	private var selectedDuration: TimeInterval = 15 * 60

	private var durationSelectionCollapsed = true
	private var dateSelectionCollapsed = true

	private func dateSelectionCell() -> DynamicCell {
		DynamicCell.custom(
			withIdentifier: OnBehalfDateSelectionCell.dynamicTableViewCellReuseIdentifier,
			action: .execute(block: { controller, cell in
				if let validationDateSelectionCell = cell as? OnBehalfDateSelectionCell,
				   let tableViewController = controller as? DynamicTableViewController {

					self.dateSelectionCollapsed = !self.dateSelectionCollapsed

					guard let indexPath = tableViewController.tableView.indexPath(for: validationDateSelectionCell) else {
						return
					}

					tableViewController.tableView.beginUpdates()
					tableViewController.tableView.reloadRows(at: [indexPath], with: .none)
					tableViewController.tableView.endUpdates()
				}
			}),
			accessoryAction: .none
		) { [weak self] _, cell, _ in
			guard let self = self else { return }

			if let dateSelectionCell = cell as? OnBehalfDateSelectionCell {

				dateSelectionCell.didSelectDate = { [weak self] date in
					self?.selectedDate = date
				}

				dateSelectionCell.selectedDate = self.selectedDate
				dateSelectionCell.isCollapsed = self.dateSelectionCollapsed
			}
		}
	}

	private func durationSelectionCell() -> DynamicCell {
		DynamicCell.custom(
			withIdentifier: OnBehalfDurationSelectionCell.dynamicTableViewCellReuseIdentifier,
			action: .execute(block: { controller, cell in
				if let durationSelectionCell = cell as? OnBehalfDurationSelectionCell,
				   let tableViewController = controller as? DynamicTableViewController {

					self.durationSelectionCollapsed = !self.durationSelectionCollapsed

					guard let indexPath = tableViewController.tableView.indexPath(for: durationSelectionCell) else {
						return
					}

					tableViewController.tableView.beginUpdates()
					tableViewController.tableView.reloadRows(at: [indexPath], with: .none)
					tableViewController.tableView.endUpdates()
				}
			}),
			accessoryAction: .none
		) { [weak self] _, cell, _ in
			guard let self = self else { return }

			if let durationSelectionCell = cell as? OnBehalfDurationSelectionCell {
				durationSelectionCell.didSelectDuration = { [weak self] duration in
					self?.selectedDuration = duration
				}

				durationSelectionCell.selectedDuration = self.selectedDuration
				durationSelectionCell.isCollapsed = self.durationSelectionCollapsed
			}
		}
	}
	
}
