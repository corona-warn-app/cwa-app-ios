//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension TicketValidationAccessToken {

	static func fake(
		iss: String = "",
		iat: Date? = nil,
		exp: Date? = nil,
		sub: String = "",
		aud: String = "",
		jti: String = "",
		v: String = "",
		t: Int = 0,
		vc: TicketValidationConditions = .fake()
	) -> TicketValidationAccessToken {
		return TicketValidationAccessToken(
			iss: iss,
			iat: iat,
			exp: exp,
			sub: sub,
			aud: aud,
			jti: jti,
			v: v,
			t: t,
			vc: vc
		)
	}

}
