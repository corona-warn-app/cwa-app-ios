////
// 🦠 Corona-Warn-App
//

import OpenCombine

class MockEventStore: EventStoring, EventProviding {

	// MARK: - Protocol EventStoring

	func createTraceLocation(_ traceLocation: TraceLocation) -> VoidResult {
		traceLocationsPublisher.value.append(traceLocation)
		return .success(())
	}

	func deleteTraceLocation(id: String) -> EventStoring.VoidResult {
		traceLocationsPublisher.value.removeAll { $0.guid == id }
		return .success(())
	}

	func deleteAllTraceLocations() -> EventStoring.VoidResult {
		traceLocationsPublisher.value = ([])
		return .success(())
	}

	func createCheckin(_ checkin: Checkin) -> EventStoring.IdResult {
		let id = UUID().hashValue
		let checkinWithId = makeUpdatedCheckin(with: checkin, id: id)
		checkinsPublisher.value.append(checkinWithId)
		return .success(id)
	}

	func updateCheckin(id: Int, endDate: Date) -> EventStoring.VoidResult {
		var checkins = checkinsPublisher.value
		guard let checkin = (checkins.first { $0.id == id }) else {
			return .failure(.database(.unknown))
		}
		let updatedCheckin = makeUpdatedCheckin(with: checkin, checkinEndDate: endDate)
		checkins.removeAll { $0.id == id }
		checkins.append(updatedCheckin)
		checkinsPublisher.send(checkins)
		return .success(())
	}

	func updateCheckin(id: Int, targetCheckinEndDate: Date) -> EventStoring.VoidResult {
		var checkins = checkinsPublisher.value
		guard let checkin = (checkins.first { $0.id == id }) else {
			return .failure(.database(.unknown))
		}
		let updatedCheckin = makeUpdatedCheckin(with: checkin, targetCheckinEndDate: targetCheckinEndDate)
		checkins.removeAll { $0.id == id }
		checkins.append(updatedCheckin)
		checkinsPublisher.send(checkins)
		return .success(())
	}

	func deleteCheckin(id: Int) -> EventStoring.VoidResult {
		checkinsPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

	func deleteAllCheckins() -> EventStoring.VoidResult {
		checkinsPublisher.value = ([])
		return .success(())
	}

	func createTraceTimeIntervalMatch(_ match: TraceTimeIntervalMatch) -> EventStoring.IdResult {
		let id = UUID().hashValue
		let traceTimeIntervalMatch = makeUpdatedTraceTimeIntervalMatch(with: match, id: id)
		traceTimeIntervalMatchesPublisher.value.append(traceTimeIntervalMatch)
		return .success(id)
	}

	func deleteTraceTimeIntervalMatch(id: Int) -> EventStoring.VoidResult {
		traceTimeIntervalMatchesPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

	func createTraceWarningPackageMetadata(_ metadata: TraceWarningPackageMetadata) -> EventStoring.IdResult {
		let id = UUID().hashValue
		let traceWarningPackageMetadata = makeUpdatedTraceWarningPackageMetadata(with: metadata, id: id)
		traceWarningPackageMetadatasPublisher.value.append(traceWarningPackageMetadata)
		return .success(id)
	}

	func deleteTraceWarningPackageMetadata(id: Int) -> EventStoring.VoidResult {
		traceWarningPackageMetadatasPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

	// MARK: - Protocol EventProviding

	var traceLocationsPublisher = CurrentValueSubject<[TraceLocation], Never>([])

	var checkinsPublisher = CurrentValueSubject<[Checkin], Never>([])

	var traceTimeIntervalMatchesPublisher = OpenCombine.CurrentValueSubject<[TraceTimeIntervalMatch], Never>([])

	var traceWarningPackageMetadatasPublisher = OpenCombine.CurrentValueSubject<[TraceWarningPackageMetadata], Never>([])

	// MARK: - Private

	private func makeUpdatedTraceTimeIntervalMatch(with match: TraceTimeIntervalMatch, id: Int) -> TraceTimeIntervalMatch {
		TraceTimeIntervalMatch(
			id: match.id,
			checkinId: match.checkinId,
			traceWarningPackageId: match.traceWarningPackageId,
			traceLocationGUID: match.traceLocationGUID,
			transmissionRiskLevel: match.transmissionRiskLevel,
			startIntervalNumber: match.startIntervalNumber,
			endIntervalNumber: match.endIntervalNumber
		)
	}

	private func makeUpdatedTraceWarningPackageMetadata(with metadata: TraceWarningPackageMetadata, id: Int) -> TraceWarningPackageMetadata {
		TraceWarningPackageMetadata(
			id: id,
			region: metadata.region,
			eTag: metadata.eTag
		)
	}

	private func makeUpdatedCheckin(with checkin: Checkin, id: Int) -> Checkin {
		Checkin(
			id: id,
			traceLocationGUID: checkin.traceLocationGUID,
			traceLocationVersion: checkin.traceLocationVersion,
			traceLocationType: checkin.traceLocationType,
			traceLocationDescription: checkin.traceLocationDescription,
			traceLocationAddress: checkin.traceLocationAddress,
			traceLocationStart: checkin.traceLocationStart,
			traceLocationEnd: checkin.traceLocationEnd,
			traceLocationDefaultCheckInLengthInMinutes: checkin.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: checkin.traceLocationSignature,
			checkinStartDate: checkin.checkinStartDate,
			checkinEndDate: checkin.checkinEndDate,
			targetCheckinEndDate: checkin.targetCheckinEndDate,
			createJournalEntry: checkin.createJournalEntry
		)
	}

	private func makeUpdatedCheckin(with checkin: Checkin, targetCheckinEndDate: Date) -> Checkin {
		Checkin(
			id: checkin.id,
			traceLocationGUID: checkin.traceLocationGUID,
			traceLocationVersion: checkin.traceLocationVersion,
			traceLocationType: checkin.traceLocationType,
			traceLocationDescription: checkin.traceLocationDescription,
			traceLocationAddress: checkin.traceLocationAddress,
			traceLocationStart: checkin.traceLocationStart,
			traceLocationEnd: checkin.traceLocationEnd,
			traceLocationDefaultCheckInLengthInMinutes: checkin.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: checkin.traceLocationSignature,
			checkinStartDate: checkin.checkinStartDate,
			checkinEndDate: checkin.checkinEndDate,
			targetCheckinEndDate: targetCheckinEndDate,
			createJournalEntry: checkin.createJournalEntry
		)
	}

	private func makeUpdatedCheckin(with checkin: Checkin, checkinEndDate: Date) -> Checkin {
		Checkin(
			id: checkin.id,
			traceLocationGUID: checkin.traceLocationGUID,
			traceLocationVersion: checkin.traceLocationVersion,
			traceLocationType: checkin.traceLocationType,
			traceLocationDescription: checkin.traceLocationDescription,
			traceLocationAddress: checkin.traceLocationAddress,
			traceLocationStart: checkin.traceLocationStart,
			traceLocationEnd: checkin.traceLocationEnd,
			traceLocationDefaultCheckInLengthInMinutes: checkin.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: checkin.traceLocationSignature,
			checkinStartDate: checkin.checkinStartDate,
			checkinEndDate: checkinEndDate,
			targetCheckinEndDate: checkin.targetCheckinEndDate,
			createJournalEntry: checkin.createJournalEntry
		)
	}
}
