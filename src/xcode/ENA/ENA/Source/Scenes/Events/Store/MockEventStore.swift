////
// 🦠 Corona-Warn-App
//

import OpenCombine

class MockEventStore: EventStoring, EventProviding {

	// MARK: - Protocol EventStoring

	func createEvent(id: String, description: String, start: Date, end: Date, defaultCheckInLengthInMinutes: Int, signature: String) -> EventStoring.VoidResult {
		eventsPublisher.value.append(
			Event(
				id: id,
				description: description,
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

	func createCheckin(eventId: String, start: Int, end: Int) -> EventStoring.IdResult {
		checkingPublisher.value.append(
			Checkin(
				eventId: eventId,
				start: start,
				end: end
			)
		)
		return .success((checkingPublisher.value.count - 1))
	}

	func deleteCheckin(id: Int) -> EventStoring.VoidResult {
		checkingPublisher.value.remove(at: id)
		return .success(())
	}

	func updateCheckin(id: Int, start: Int, end: Int) -> EventStoring.VoidResult {
		var checkins = checkingPublisher.value
		let checkin = checkins[id]
		let updatedCheckin = Checkin(eventId: checkin.eventId, start: start, end: end)
		checkins.remove(at: id)
		checkins.insert(updatedCheckin, at: id)
		checkingPublisher.send(checkins)
		return .success(())
	}

	// MARK: - Protocol EventProviding

	var eventsPublisher = CurrentValueSubject<[Event], Never>([])

	var checkingPublisher = CurrentValueSubject<[Checkin], Never>([])

}
