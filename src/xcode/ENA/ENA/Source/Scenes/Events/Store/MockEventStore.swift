////
// 🦠 Corona-Warn-App
//

import OpenCombine

class MockEventStore: EventStoring, EventProviding {

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
		eventsPublisher.value.append(
			Event(
				id: id,
				description: description,
				address: address,
				start: start,
				end: end,
				defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
				signature: signature
			)
		)
		return .success(())
	}

	func deleteEvent(id: String) -> EventStoring.VoidResult {
		eventsPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

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
		checkingPublisher.value.append(
			Checkin(
				id: checkingPublisher.value.count,
				eventId: eventId,
				eventType: eventType,
				eventDescription: eventDescription,
				eventAddress: eventAddress,
				eventStart: eventStart,
				eventEnd: eventEnd,
				eventSignature: eventSignature,
				checkinStart: checkinStart,
				checkinEnd: checkinEnd
			)
		)
		return .success((checkingPublisher.value.count - 1))
	}

	func deleteCheckin(id: Int) -> EventStoring.VoidResult {
		checkingPublisher.value.remove(at: id)
		return .success(())
	}

	func updateCheckin(id: Int, end: Date) -> EventStoring.VoidResult {
		var checkins = checkingPublisher.value
		var checkin = checkins[id]
		checkin.update(checkinEnd: end)
		checkins.remove(at: id)
		checkins.insert(checkin, at: id)
		checkingPublisher.send(checkins)
		return .success(())
	}

	// MARK: - Protocol EventProviding

	var eventsPublisher = CurrentValueSubject<[Event], Never>([])

	var checkingPublisher = CurrentValueSubject<[Checkin], Never>([])

}
