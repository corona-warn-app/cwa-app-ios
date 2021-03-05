////
// 🦠 Corona-Warn-App
//

import OpenCombine

class MockEventStore: EventStoring, EventProviding {

	// MARK: - Protocol EventStoring

	func createEvent(event: Event) -> EventStoring.VoidResult {
		eventsPublisher.value.append(event)
		return .success(())
	}

	func deleteEvent(id: String) -> EventStoring.VoidResult {
		eventsPublisher.value.removeAll { $0.id == id }
		return .success(())
	}

	func createCheckin(checkin: Checkin) -> EventStoring.IdResult {
		checkingPublisher.value.append(checkin)
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
