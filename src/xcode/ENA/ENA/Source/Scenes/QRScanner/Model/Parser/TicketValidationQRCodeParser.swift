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
		guard let jsonData = qrCode.data(using: .utf8), let ticketValidationInitializationData = try? JSONDecoder().decode(TicketValidationInitializationData.self, from: jsonData) else {
			completion(.failure(.ticketValidation(.INIT_DATA_PARSE_ERR)))
			return
		}

		guard ticketValidationInitializationData.`protocol`.uppercased() == "DCCVALIDATION" else {
			completion(.failure(.ticketValidation(.INIT_DATA_PROTOCOL_INVALID)))
			return
		}

		guard !ticketValidationInitializationData.subject.isEmpty else {
			completion(.failure(.ticketValidation(.INIT_DATA_SUBJECT_EMPTY)))
			return
		}

		guard !ticketValidationInitializationData.serviceProvider.isEmpty else {
			completion(.failure(.ticketValidation(.INIT_DATA_SP_EMPTY)))
			return
		}

		completion(.success(.ticketValidation(ticketValidationInitializationData)))
	}
	
}
