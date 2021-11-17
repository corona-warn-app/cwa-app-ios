//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

extension TicketValidationResult {

	static func fake(
		iss: String = "",
		iat: Int = 0,
		exp: Int = 0,
		sub: String = "",
		category: String = "",
		result: TicketValidationResult.Result = .OK,
		results: [TicketValidationResult.ResultItem] = [.fake()],
		confirmation: String = ""
	) -> TicketValidationResult {
		return .init(
			iss: iss,
			iat: iat,
			exp: exp,
			sub: sub,
			category: category,
			result: result,
			results: results,
			confirmation: confirmation
		)
	}

}

extension TicketValidationResult.ResultItem {

	static func fake(
		identifier: String = "",
		result: TicketValidationResult.Result = .OK,
		type: String = "",
		details: String = ""
	) -> TicketValidationResult.ResultItem {
		return .init(
			identifier: identifier,
			result: result,
			type: type,
			details: details
		)
	}

}

#endif
