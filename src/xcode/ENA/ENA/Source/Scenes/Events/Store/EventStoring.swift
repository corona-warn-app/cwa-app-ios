////
// 🦠 Corona-Warn-App
//

import OpenCombine

enum EventStoringError: Error {
	case database(SQLiteErrorCode)
	case timeout
}

protocol EventStoring {

	typealias IdResult = Result<Int, EventStoringError>
	typealias VoidResult = Result<Void, EventStoringError>

	@discardableResult
	func createTraceLocation(_ traceLocation: TraceLocation) -> VoidResult

	@discardableResult
	func deleteTraceLocation(id: String) -> VoidResult

	@discardableResult
	func deleteAllTraceLocations() -> VoidResult

	@discardableResult
	func createCheckin(_ checkin: Checkin) -> IdResult

	@discardableResult
	func updateCheckin(
		id: Int,
		endDate: Date
	) -> VoidResult

	@discardableResult
	func deleteCheckin(id: Int) -> VoidResult

	@discardableResult
	func deleteAllCheckins() -> VoidResult

	@discardableResult
	func createTraceTimeIntervalMatch(_ match: TraceTimeIntervalMatch) -> IdResult

	@discardableResult
	func deleteTraceTimeIntervalMatch(id: Int) -> VoidResult

	@discardableResult
	func createTraceWarningPackageMetadata(_ metadata: TraceWarningPackageMetadata) -> IdResult

	@discardableResult
	func deleteTraceWarningPackageMetadata(id: Int) -> VoidResult
}

protocol EventProviding {
	var traceLocationsPublisher: OpenCombine.CurrentValueSubject<[TraceLocation], Never> { get }
	var checkinsPublisher: OpenCombine.CurrentValueSubject<[Checkin], Never> { get }
	var traceTimeIntervalMatchesPublisher: OpenCombine.CurrentValueSubject<[TraceTimeIntervalMatch], Never> { get }
	var traceWarningPackageMetadatasPublisher: OpenCombine.CurrentValueSubject<[TraceWarningPackageMetadata], Never> { get }
}
