//
// 🦠 Corona-Warn-App
//

import Foundation

struct TicketValidationAccessTokenReceiveModel: StringDecodable, MetaDataProviding {
	
	// MARK: - Protocol StringDecodable
	
	static func make(with data: Data) -> Result<TicketValidationAccessTokenReceiveModel, ModelDecodingError> {
		
		guard let string = String(data: data, encoding: .utf8) else {
			return .failure(.STRING_DECODING)
		}
		
		return .success(TicketValidationAccessTokenReceiveModel(token: string))
	}
	
	// MARK: - Protocol MetaDataProviding

	var metaData: MetaData = MetaData()
	
	// MARK: - Internal

	let token: String
	
	init(token: String ) {
		self.token = token
	}
}
