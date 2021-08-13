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

		if let startDate = traceLocation.startDate, startDate.timeIntervalSince1970 > 0 {
			selectedDate = startDate
		} else {
			selectedDate = Date()
		}

		selectedDuration = TimeInterval(traceLocation.suggestedCheckoutLengthInMinutes(fallback: 120) * 60)
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
					traceLocationCell(),
					.subheadline(
						text: AppStrings.OnBehalfCheckinSubmission.DateTimeSelection.description,
						color: .enaColor(for: .textPrimary2)
					),
					dateSelectionCell(),
					.space(height: 8),
					durationSelectionCell()
				]
			)
		])
	}

	// MARK: - Private

	private let traceLocation: TraceLocation
	private let onPrimaryButtonTap: (Checkin) -> Void

	private var selectedDate: Date
	private var selectedDuration: TimeInterval

	private var durationSelectionCollapsed = true
	private var dateSelectionCollapsed = true

	private func traceLocationCell() -> DynamicCell {
		DynamicCell.custom(
			withIdentifier: EventTableViewCell.dynamicTableViewCellReuseIdentifier,
			accessoryAction: .none
		) { [weak self] _, cell, _ in
			guard let self = self, let traceLocationCell = cell as? EventTableViewCell else {
				return
			}

			traceLocationCell.configure(
				cellModel: OnBehalfTraceLocationCellModel(traceLocation: self.traceLocation),
				onButtonTap: {}
			)
		}
	}

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

					if !self.durationSelectionCollapsed {
						tableViewController.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
					}
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
