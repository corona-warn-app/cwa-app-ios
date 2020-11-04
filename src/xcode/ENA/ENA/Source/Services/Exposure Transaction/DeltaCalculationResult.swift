import Foundation

struct DeltaCalculationResult {
	init(
		remoteDays: Set<String>,
		remoteHours: Set<Int>,
		localDays: Set<String>,
		localHours: Set<Int>
	) {
		missingDays = remoteDays.subtracting(localDays)
		missingHours = remoteHours.subtracting(localHours)
	}

	// MARK: Properties

	let missingDays: Set<String>
	let missingHours: Set<Int>
}
