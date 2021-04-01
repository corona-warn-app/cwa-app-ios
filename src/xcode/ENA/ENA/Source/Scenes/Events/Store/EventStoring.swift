////
// 🦠 Corona-Warn-App
//

import OpenCombine

typealias EventStoringProviding = EventStoring & EventProviding

protocol EventStoring {

	@discardableResult
	func createTraceLocation(_ traceLocation: TraceLocation) -> SecureSQLStore.VoidResult

	@discardableResult
	func updateTraceLocation(_ traceLocation: TraceLocation) -> SecureSQLStore.VoidResult

	@discardableResult
	func deleteTraceLocation(id: Data) -> SecureSQLStore.VoidResult

	@discardableResult
	func deleteAllTraceLocations() -> SecureSQLStore.VoidResult

	@discardableResult
	func createCheckin(_ checkin: Checkin) -> SecureSQLStore.IdResult

	@discardableResult
	func updateCheckin(_ checkin: Checkin) -> SecureSQLStore.VoidResult

	@discardableResult
	func deleteCheckin(id: Int) -> SecureSQLStore.VoidResult

	@discardableResult
	func deleteAllCheckins() -> SecureSQLStore.VoidResult

	@discardableResult
	func createTraceTimeIntervalMatch(_ match: TraceTimeIntervalMatch) -> SecureSQLStore.IdResult

	@discardableResult
	func deleteTraceTimeIntervalMatch(id: Int) -> SecureSQLStore.VoidResult

	@discardableResult
	func createTraceWarningPackageMetadata(_ metadata: TraceWarningPackageMetadata) -> SecureSQLStore.VoidResult

	@discardableResult
	func deleteTraceWarningPackageMetadata(id: Int) -> SecureSQLStore.VoidResult

	@discardableResult
	func deleteAllTraceWarningPackageMetadata() -> SecureSQLStore.VoidResult

	@discardableResult
	func cleanup() -> SecureSQLStore.VoidResult

	@discardableResult
	func cleanup(timeout: TimeInterval) -> SecureSQLStore.VoidResult
	
	@discardableResult
	func reset() -> SecureSQLStore.VoidResult
}

protocol EventProviding {
	var traceLocationsPublisher: OpenCombine.CurrentValueSubject<[TraceLocation], Never> { get }
	var checkinsPublisher: OpenCombine.CurrentValueSubject<[Checkin], Never> { get }
	var traceTimeIntervalMatchesPublisher: OpenCombine.CurrentValueSubject<[TraceTimeIntervalMatch], Never> { get }
	var traceWarningPackageMetadatasPublisher: OpenCombine.CurrentValueSubject<[TraceWarningPackageMetadata], Never> { get }
}
