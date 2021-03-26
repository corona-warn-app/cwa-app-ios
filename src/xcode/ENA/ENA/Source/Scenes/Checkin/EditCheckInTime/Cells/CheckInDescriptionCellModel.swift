////
// 🦠 Corona-Warn-App
//

import Foundation

final class CheckInDescriptionCellModel {

	// MARK: - Init

	init( checkIn: Checkin) {
		self.locationType = "Vereinsaktivität" // checkIn.traceLocationType.title
		self.description = "Jahrestreffen der deutschen SAP Anwendergruppe" // checkIn.traceLocationDescription
		self.address = checkIn.traceLocationAddress
	}

	// MARK: - Public

	// MARK: - Internal

	let locationType: String
	let description: String
	let address: String

	// MARK: - Private

}
