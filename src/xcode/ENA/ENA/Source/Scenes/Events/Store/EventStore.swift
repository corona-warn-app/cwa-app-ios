////
// 🦠 Corona-Warn-App
//

import OpenCombine

class EventStore: EventStoring, EventProviding {

	// MARK: - Protocol EventStoring

	func createEvent(
		id: String,
		description: String,
		address: String,
		start: Date,
		end: Date,
		defaultCheckInLengthInMinutes: Int,
		signature: String
	) -> EventStoring.VoidResult {

		return .success(())
	}

	func deleteEvent(id: String) -> EventStoring.VoidResult {

		return .success(())
	}

	// swiftlint:disable function_parameter_count
	func createCheckin(
		eventId: String,
		eventType: Int,
		eventDescription: String,
		eventAddress: String,
		eventStart: Date,
		eventEnd: Date,
		eventSignature: String,
		checkinStart: Date,
		checkinEnd: Date) -> EventStoring.IdResult {

		return .success((checkingPublisher.value.count - 1))
	}

	func deleteCheckin(id: Int) -> EventStoring.VoidResult {

		return .success(())
	}

	func updateCheckin(id: Int, end: Date) -> EventStoring.VoidResult {

		return .success(())
	}

	// MARK: - Protocol EventProviding

	var eventsPublisher = CurrentValueSubject<[Event], Never>([])

	var checkingPublisher = CurrentValueSubject<[Checkin], Never>([])
}
