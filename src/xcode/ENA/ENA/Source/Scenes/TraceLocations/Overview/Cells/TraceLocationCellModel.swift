////
// 🦠 Corona-Warn-App
//

import UIKit

struct TraceLocationCellModel {

	// MARK: - Internal

	let traceLocation = TraceLocation(guid: "", version: 0, type: .type1, description: "", address: "", startDate: Date(), endDate: Date(), defaultCheckInLengthInMinutes: 0, byteRepresentation: Data(), signature: "")

	let title: String = "Jahrestreffen der deutschen SAP Anwendergruppe"
	let location: String = "Hauptstr 3, 69115 Heidelberg"
	let time: String = "18:00 - 21:00 Uhr"
	let date: String = "21.01.2021"
	let buttonTitle: String = "Selbst einchecken"
	let accessibilityTraits: UIAccessibilityTraits = [.button]
    
}
