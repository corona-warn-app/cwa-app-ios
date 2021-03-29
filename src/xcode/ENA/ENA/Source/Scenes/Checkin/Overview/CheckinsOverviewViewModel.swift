//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import AVFoundation

class CheckinsOverviewViewModel {

	// MARK: - Init

	init(
		store: EventStoringProviding,
		onEntryCellTap: @escaping (Checkin) -> Void,
		cameraAuthorizationStatus: @escaping () -> AVAuthorizationStatus = {
			AVCaptureDevice.authorizationStatus(for: .video)
		}
	) {
		self.store = store
		self.onEntryCellTap = onEntryCellTap
        self.cameraAuthorizationStatus = cameraAuthorizationStatus

		store.checkinsPublisher
			.map { $0.sorted { $0.checkinStartDate < $1.checkinStartDate } }
			.sink { [weak self] in
				self?.update(from: $0)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case missingPermission
		case entries
	}

	@OpenCombine.Published private(set) var shouldReload: Bool = false

	var onUpdate: (() -> Void)?

	var checkinCellModels: [CheckinCellModel] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	var isEmpty: Bool {
		numberOfRows(in: Section.entries.rawValue) == 0
	}

	var isEmptyStateVisible: Bool {
		isEmpty && !showMissingPermissionSection
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .add:
			return showMissingPermissionSection ? 0 : 1
		case .missingPermission:
			return showMissingPermissionSection ? 1 : 0
		case .entries:
			return checkinCellModels.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return indexPath.section == Section.entries.rawValue
	}

	func didTapEntryCell(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		onEntryCellTap(checkinCellModels[indexPath.row].checkin)
	}

	func didTapEntryCellButton(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		let checkin = checkinCellModels[indexPath.row].checkin
		let updatedChecking = Checkin(
			id: checkin.id,
			traceLocationId: checkin.traceLocationId,
			traceLocationIdHash: checkin.traceLocationIdHash,
			traceLocationVersion: checkin.traceLocationVersion,
			traceLocationType: checkin.traceLocationType,
			traceLocationDescription: checkin.traceLocationDescription,
			traceLocationAddress: checkin.traceLocationAddress,
			traceLocationStartDate: checkin.traceLocationStartDate,
			traceLocationEndDate: checkin.traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: checkin.traceLocationDefaultCheckInLengthInMinutes,
			cryptographicSeed: checkin.cryptographicSeed,
			cnMainPublicKey: checkin.cnMainPublicKey,
			checkinStartDate: checkin.checkinStartDate,
			checkinEndDate: checkin.checkinEndDate,
			checkinCompleted: true,
			createJournalEntry: checkin.createJournalEntry
		)

		store.updateCheckin(updatedChecking)
	}

	func removeEntry(at indexPath: IndexPath) {
		store.deleteCheckin(id: checkinCellModels[indexPath.row].checkin.id)
	}

	func removeAll() {
		store.deleteAllCheckins()
	}

	func updateForCameraPermission() {
		shouldReload = true
	}

	// MARK: - Private

	private let store: EventStoringProviding
	private let onEntryCellTap: (Checkin) -> Void
	private let cameraAuthorizationStatus: () -> AVAuthorizationStatus

	private var subscriptions: [AnyCancellable] = []

	private var showMissingPermissionSection: Bool {
		let status = cameraAuthorizationStatus()

		return status != .notDetermined && status != .authorized
	}

	private func update(from checkins: [Checkin]) {
		if checkins.map({ $0.id }) != checkinCellModels.map({ $0.checkin.id }) {
			checkinCellModels = checkins.map { checkin in
				CheckinCellModel(
					checkin: checkin,
					eventProvider: store,
					onUpdate: { [weak self] in
						self?.onUpdate?()
					}
				)
			}

			shouldReload = true
		} else {
			checkinCellModels.forEach { cellModel in
				guard let checkin = checkins.first(where: { $0.id == cellModel.checkin.id }) else {
					return
				}

				cellModel.update(with: checkin)
			}
		}
	}

}
