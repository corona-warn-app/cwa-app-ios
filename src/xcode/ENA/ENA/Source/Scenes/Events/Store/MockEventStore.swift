////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class MockEventStore: EventStoring, EventProviding {
	
	// MARK: - Protocol EventStoring

	@discardableResult
	func createTraceLocation(_ traceLocation: TraceLocation) -> SecureSQLStore.VoidResult {
		traceLocationsPublisher.value = appendTraceLocationAndSort(traceLocation)
		return .success(())
	}

	@discardableResult
	func deleteTraceLocation(id: Data) -> SecureSQLStore.VoidResult {
		traceLocationsPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

	@discardableResult
	func deleteAllTraceLocations() -> SecureSQLStore.VoidResult {
		traceLocationsPublisher.value = ([])
		return .success(())
	}

	@discardableResult
	func createCheckin(_ checkin: Checkin) -> SecureSQLStore.IdResult {
		let id = UUID().hashValue
		let checkinWithId = checkin.updatedWith(id: id)
		checkinsPublisher.value = appendCheckInAndSort(checkinWithId)
		return .success(id)
	}

	@discardableResult
	func updateCheckin(_ checkin: Checkin) -> SecureSQLStore.VoidResult {
		guard let oldCheckin = (checkinsPublisher.value.first { $0.id == checkin.id }) else {
			return .failure(.database(.unknown(-1)))
		}
		let updatedCheckin = oldCheckin.updatedWith(checkin: checkin)
		checkinsPublisher.value = appendCheckInAndSort(updatedCheckin)
		return .success(())
	}

	@discardableResult
	func deleteCheckin(id: Int) -> SecureSQLStore.VoidResult {
		checkinsPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

	@discardableResult
	func deleteAllCheckins() -> SecureSQLStore.VoidResult {
		checkinsPublisher.value = ([])
		return .success(())
	}

	@discardableResult
	func createTraceTimeIntervalMatch(_ match: TraceTimeIntervalMatch) -> SecureSQLStore.IdResult {
		let id = UUID().hashValue
		let traceTimeIntervalMatch = match.updatedWith(id: id)
		traceTimeIntervalMatchesPublisher.value.append(traceTimeIntervalMatch)
		return .success(id)
	}

	@discardableResult
	func deleteTraceTimeIntervalMatch(id: Int) -> SecureSQLStore.VoidResult {
		traceTimeIntervalMatchesPublisher.value.removeAll { $0.id == id }
		return .success(())
	}
	
	func deleteAllTraceTimeIntervalMatches() -> Result<Void, SecureSQLStoreError> {
		traceTimeIntervalMatchesPublisher.value = ([])
		return .success(())
	}

	@discardableResult
	func createTraceWarningPackageMetadata(_ metadata: TraceWarningPackageMetadata) -> SecureSQLStore.VoidResult {
		traceWarningPackageMetadatasPublisher.value.append(metadata)
		return .success(())
	}

	@discardableResult
	func deleteTraceWarningPackageMetadata(id: Int) -> SecureSQLStore.VoidResult {
		traceWarningPackageMetadatasPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

	@discardableResult
	func deleteAllTraceWarningPackageMetadata() -> SecureSQLStore.VoidResult {
		traceWarningPackageMetadatasPublisher.value = ([])
		return .success(())
	}

	@discardableResult
	func cleanup() -> SecureSQLStore.VoidResult {
		return .success(())
	}

	@discardableResult
	func cleanup(timeout: TimeInterval) -> SecureSQLStore.VoidResult {
		return .success(())
	}

	@discardableResult
	func reset() -> SecureSQLStore.VoidResult {
		traceLocationsPublisher.send([TraceLocation]())
		checkinsPublisher.send([Checkin]())
		traceTimeIntervalMatchesPublisher.send([TraceTimeIntervalMatch]())
		traceWarningPackageMetadatasPublisher.send([TraceWarningPackageMetadata]())
		return .success(())
	}

	// MARK: - Protocol EventProviding

	var traceLocationsPublisher = CurrentValueSubject<[TraceLocation], Never>([])

	var checkinsPublisher = CurrentValueSubject<[Checkin], Never>([])

	var traceTimeIntervalMatchesPublisher = OpenCombine.CurrentValueSubject<[TraceTimeIntervalMatch], Never>([])

	var traceWarningPackageMetadatasPublisher = OpenCombine.CurrentValueSubject<[TraceWarningPackageMetadata], Never>([])

	private func appendCheckInAndSort(_ checkIn: Checkin) -> [Checkin] {
		var currentValues = checkinsPublisher.value
		currentValues.removeAll { $0.id == checkIn.id }
		currentValues.append(checkIn)
		currentValues.sort {
			$0.checkinEndDate > $1.checkinEndDate
		}
		return currentValues
	}

	private func appendTraceLocationAndSort(_ traceLocation: TraceLocation) -> [TraceLocation] {
		var currentValues = traceLocationsPublisher.value
		currentValues.append(traceLocation)
		currentValues.sort {
			$0.description < $1.description
		}
		return currentValues
	}

}

private extension TraceTimeIntervalMatch {

	func updatedWith(id: Int) -> TraceTimeIntervalMatch {
		TraceTimeIntervalMatch(
			id: id,
			checkinId: self.checkinId,
			traceWarningPackageId: self.traceWarningPackageId,
			traceLocationId: self.traceLocationId,
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

private extension TraceLocation {
	func updatedWith(traceLocation: TraceLocation) -> TraceLocation {
		TraceLocation(
			id: id,
			version: traceLocation.version,
			type: traceLocation.type,
			description: traceLocation.description,
			address: traceLocation.address,
			startDate: traceLocation.startDate,
			endDate: traceLocation.endDate,
			defaultCheckInLengthInMinutes: traceLocation.defaultCheckInLengthInMinutes,
			cryptographicSeed: traceLocation.cryptographicSeed,
			cnPublicKey: traceLocation.cnPublicKey
		)
	}
}

private extension Checkin {
	func updatedWith(id: Int) -> Checkin {
		Checkin(
			id: id,
			traceLocationId: self.traceLocationId,
			traceLocationIdHash: self.traceLocationIdHash,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStartDate: self.traceLocationStartDate,
			traceLocationEndDate: self.traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			cryptographicSeed: self.cryptographicSeed,
			cnPublicKey: self.cnPublicKey,
			checkinStartDate: self.checkinStartDate,
			checkinEndDate: self.checkinEndDate,
			checkinCompleted: self.checkinCompleted,
			createJournalEntry: self.createJournalEntry,
			checkinSubmitted: self.checkinSubmitted
		)
	}

	func updatedWith(checkin: Checkin) -> Checkin {
		Checkin(
			id: self.id,
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
			cnPublicKey: checkin.cnPublicKey,
			checkinStartDate: checkin.checkinStartDate,
			checkinEndDate: checkin.checkinEndDate,
			checkinCompleted: checkin.checkinCompleted,
			createJournalEntry: checkin.createJournalEntry,
			checkinSubmitted: checkin.checkinSubmitted
		)
	}
}
