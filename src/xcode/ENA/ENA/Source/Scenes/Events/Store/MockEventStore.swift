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
		let checkinWithId = checkin.updatedWith(id: id)
		checkinsPublisher.value.append(checkinWithId)
		return .success(id)
	}

	func updateCheckin(id: Int, endDate: Date) -> EventStoring.VoidResult {
		var checkins = checkinsPublisher.value
		guard let checkin = (checkins.first { $0.id == id }) else {
			return .failure(.database(.unknown))
		}
		let updatedCheckin = checkin.updatedWith(checkinEndDate: endDate)
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
		let updatedCheckin = checkin.updatedWith(targetCheckinEndDate: targetCheckinEndDate)
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
		let traceTimeIntervalMatch = match.updatedWith(id: id)
		traceTimeIntervalMatchesPublisher.value.append(traceTimeIntervalMatch)
		return .success(id)
	}

	func deleteTraceTimeIntervalMatch(id: Int) -> EventStoring.VoidResult {
		traceTimeIntervalMatchesPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

	func createTraceWarningPackageMetadata(_ metadata: TraceWarningPackageMetadata) -> EventStoring.IdResult {
		let id = UUID().hashValue
		let traceWarningPackageMetadata = metadata.updatedWith(id: id)
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

}

private extension TraceTimeIntervalMatch {

	func updatedWith(id: Int) -> TraceTimeIntervalMatch {
		TraceTimeIntervalMatch(
			id: id,
			checkinId: self.checkinId,
			traceWarningPackageId: self.traceWarningPackageId,
			traceLocationGUID: self.traceLocationGUID,
			transmissionRiskLevel: self.transmissionRiskLevel,
			startIntervalNumber: self.startIntervalNumber,
			endIntervalNumber: self.endIntervalNumber
		)
	}
}

private extension TraceWarningPackageMetadata {

	func updatedWith(id: Int) -> TraceWarningPackageMetadata {
		TraceWarningPackageMetadata(
			id: id,
			region: self.region,
			eTag: self.eTag
		)
	}
}

private extension Checkin {
	func updatedWith(id: Int) -> Checkin {
		Checkin(
			id: id,
			traceLocationGUID: self.traceLocationGUID,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStart: self.traceLocationStart,
			traceLocationEnd: self.traceLocationEnd,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: self.traceLocationSignature,
			checkinStartDate: self.checkinStartDate,
			checkinEndDate: self.checkinEndDate,
			targetCheckinEndDate: self.targetCheckinEndDate,
			createJournalEntry: self.createJournalEntry
		)
	}

	func updatedWith(targetCheckinEndDate: Date) -> Checkin {
		Checkin(
			id: self.id,
			traceLocationGUID: self.traceLocationGUID,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStart: self.traceLocationStart,
			traceLocationEnd: self.traceLocationEnd,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: self.traceLocationSignature,
			checkinStartDate: self.checkinStartDate,
			checkinEndDate: self.checkinEndDate,
			targetCheckinEndDate: targetCheckinEndDate,
			createJournalEntry: self.createJournalEntry
		)
	}

	func updatedWith(checkinEndDate: Date) -> Checkin {
		Checkin(
			id: self.id,
			traceLocationGUID: self.traceLocationGUID,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStart: self.traceLocationStart,
			traceLocationEnd: self.traceLocationEnd,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: self.traceLocationSignature,
			checkinStartDate: self.checkinStartDate,
			checkinEndDate: checkinEndDate,
			targetCheckinEndDate: self.targetCheckinEndDate,
			createJournalEntry: self.createJournalEntry
		)
	}
}
