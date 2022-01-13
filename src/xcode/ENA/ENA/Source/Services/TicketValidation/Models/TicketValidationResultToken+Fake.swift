//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

extension TicketValidationResultToken {

	static func fake(
		iss: String = "",
		iat: Date? = nil,
		exp: Date? = nil,
		sub: String = "",
		category: [String] = [],
		result: TicketValidationResultToken.Result = .passed,
		results: [TicketValidationResultToken.ResultItem] = [.fake()],
		confirmation: String = ""
	) -> TicketValidationResultToken {
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

extension TicketValidationResultToken.ResultItem {

	static func fake(
		identifier: String = "",
		result: TicketValidationResultToken.Result = .passed,
		type: String = "",
		details: String = ""
	) -> TicketValidationResultToken.ResultItem {
		return .init(
			identifier: identifier,
			result: result,
			type: type,
			details: details
		)
	}

}

#endif
