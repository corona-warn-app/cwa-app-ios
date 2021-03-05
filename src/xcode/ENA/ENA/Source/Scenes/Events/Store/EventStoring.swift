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
	func createEvent(event: Event) -> VoidResult

	@discardableResult
	func deleteEvent(
		id: String
	) -> VoidResult

	@discardableResult
	func createCheckin(checkin: Checkin) -> IdResult

	@discardableResult
	func deleteCheckin(
		id: Int
	) -> VoidResult

	@discardableResult
	func updateCheckin(
		id: Int,
		end: Date
	) -> VoidResult
}

protocol EventProviding {
	var eventsPublisher: OpenCombine.CurrentValueSubject<[Event], Never> { get }
	var checkingPublisher: OpenCombine.CurrentValueSubject<[Checkin], Never> { get }
}
