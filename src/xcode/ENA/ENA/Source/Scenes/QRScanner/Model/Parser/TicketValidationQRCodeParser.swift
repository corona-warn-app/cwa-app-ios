//
// 🦠 Corona-Warn-App
//

import Foundation

class TicketValidationQRCodeParser: QRCodeParsable {
	
	// MARK: - Init

	init() {
	}

	// MARK: - Protocol QRCodeParsable
	
	func parse(
		qrCode: String,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	) {
		Log.info("Parse ticket validation data.")

		guard let jsonData = qrCode.data(using: .utf8), let ticketValidationInitializationData = try? JSONDecoder().decode(TicketValidationInitializationData.self, from: jsonData) else {
			let error = QRCodeParserError.ticketValidation(.INIT_DATA_PARSE_ERR)
			Log.info("Failed parsing ticket validation data with error: \(error)")
			completion(.failure(error))
			return
		}

		guard ticketValidationInitializationData.`protocol`.uppercased() == "DCCVALIDATION" else {
			let error = QRCodeParserError.ticketValidation(.INIT_DATA_PROTOCOL_INVALID)
			Log.info("Failed parsing ticket validation data with error: \(error)")
			completion(.failure(error))
			return
		}

		guard !ticketValidationInitializationData.subject.isEmpty else {
			let error = QRCodeParserError.ticketValidation(.INIT_DATA_SUBJECT_EMPTY)
			Log.info("Failed parsing ticket validation data with error: \(error)")
			completion(.failure(error))
			return
		}

		guard !ticketValidationInitializationData.serviceProvider.isEmpty else {
			let error = QRCodeParserError.ticketValidation(.INIT_DATA_SP_EMPTY)
			Log.info("Failed parsing ticket validation data with error: \(error)")
			completion(.failure(error))
			return
		}

		completion(.success(.ticketValidation(ticketValidationInitializationData)))
	}
	
}
