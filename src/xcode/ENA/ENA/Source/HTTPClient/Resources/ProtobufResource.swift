//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftProtobuf

struct ProtobufResource<P>: HTTPResource where P: SwiftProtobuf.Message {

	init(
//		environmentProvider: EnvironmentProviding = Environments(),
//		session: URLSession = .coronaWarnSession(
//			configuration: .cachingSessionConfiguration()
//		),
		signatureVerifier: SignatureVerifier = SignatureVerifier()
	) {
//		self.session = session
//		self.environmentProvider = environmentProvider
		self.signatureVerifier = signatureVerifier
	}

	typealias Model = P

	var url: URL = URL(staticString: "http://")

	var method: HTTP.Method = .get

	func decode(_ data: Data?) -> Result<P, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}
		guard let package = SAPDownloadedPackage(compressedData: data) else {
			return .failure(.packageCreation)
		}
		guard signatureVerifier.verify(package) else {
			return .failure(.signatureVerification)
		}

		do {
			let model = try P(serializedData: package.bin)
			return Result.success(model)
		} catch {
			return Result.failure(.decoding)
		}
	}

	private let signatureVerifier: SignatureVerifier
}
