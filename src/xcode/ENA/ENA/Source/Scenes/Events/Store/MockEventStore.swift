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
		checkinsPublisher.value.append(checkin)
		return .success((checkinsPublisher.value.count - 1))
	}

	func updateCheckin(id: Int, endDate: Date) -> EventStoring.VoidResult {
		var checkins = checkinsPublisher.value
		var checkin = checkins[id]
		checkin.update(checkinEndDate: endDate)
		checkins.remove(at: id)
		checkins.insert(checkin, at: id)
		checkinsPublisher.send(checkins)
		return .success(())
	}

	func updateCheckin(id: Int, targetCheckinEndDate: Date) -> EventStoring.VoidResult {
		var checkins = checkinsPublisher.value
		var checkin = checkins[id]
		checkin.update(targetCheckinEndDate: targetCheckinEndDate)
		checkins.remove(at: id)
		checkins.insert(checkin, at: id)
		checkinsPublisher.send(checkins)
		return .success(())
	}

	func deleteCheckin(id: Int) -> EventStoring.VoidResult {
		checkinsPublisher.value.remove(at: id)
		return .success(())
	}

	func deleteAllCheckins() -> EventStoring.VoidResult {
		checkinsPublisher.value = ([])
		return .success(())
	}

	func createTraceTimeIntervalMatch(_ match: TraceTimeIntervalMatch) -> EventStoring.IdResult {
		traceTimeIntervalMatchesPublisher.value.append(match)
		return .success((traceTimeIntervalMatchesPublisher.value.count - 1))
	}

	func deleteTraceTimeIntervalMatch(id: Int) -> EventStoring.VoidResult {
		traceTimeIntervalMatchesPublisher.value.remove(at: id)
		return .success(())
	}

	func createTraceWarningPackageMetadata(_ match: TraceWarningPackageMetadata) -> EventStoring.IdResult {
		traceWarningPackageMetadatasPublisher.value.append(match)
		return .success((traceWarningPackageMetadatasPublisher.value.count - 1))
	}

	func deleteTraceWarningPackageMetadata(id: Int) -> EventStoring.VoidResult {
		traceWarningPackageMetadatasPublisher.value.remove(at: id)
		return .success(())
	}

	// MARK: - Protocol EventProviding

	var traceLocationsPublisher = CurrentValueSubject<[TraceLocation], Never>([])

	var checkinsPublisher = CurrentValueSubject<[Checkin], Never>([])

	var traceTimeIntervalMatchesPublisher = OpenCombine.CurrentValueSubject<[TraceTimeIntervalMatch], Never>([])

	var traceWarningPackageMetadatasPublisher = OpenCombine.CurrentValueSubject<[TraceWarningPackageMetadata], Never>([])

}
