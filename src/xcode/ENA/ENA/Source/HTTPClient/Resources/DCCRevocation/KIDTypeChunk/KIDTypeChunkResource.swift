//
// 🦠 Corona-Warn-App
//

import Foundation

enum KIDTypeChunkResourceError: Error {
	case DCC_RL_KTXY_CHUNK_SERVER_ERROR
	case DCC_RL_KTXY_CHUNK_CLIENT_ERROR
	case DCC_RL_KTXY_CHUNK_NO_NETWORK
	case DCC_RL_KTXY_INVALID_SIGNATURE
}

struct KIDTypeChunkResource: Resource {

	init(
		kid: String,
		hashType: String,
		x: String,
		y: String,
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.trustEvaluation = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
		self.locator = Locator(
			kid: kid,
			hashType: hashType,
			x: x,
			y: y
		)
		self.type = .caching([.loadOnlyOnceADay])
		self.sendResource = EmptySendResource()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_Dgc_RevocationChunk>(
			signatureVerifier: signatureVerifier
		)
	}
	
	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = ProtobufReceiveResource<SAP_Internal_Dgc_RevocationChunk>
	typealias CustomError = KIDTypeChunkResourceError

	let trustEvaluation: TrustEvaluating
	let locator: Locator
	let type: ServiceType
	let sendResource: EmptySendResource
	let receiveResource: ProtobufReceiveResource<SAP_Internal_Dgc_RevocationChunk>
	
	func customError(for error: ServiceError<KIDTypeChunkResourceError>, responseBody: Data?) -> KIDTypeChunkResourceError? {
		switch error {
		case .resourceError(let error):
			if case .signatureVerification = error {
				return .DCC_RL_KTXY_INVALID_SIGNATURE
			} else {
				return nil
			}
		case .transportationError:
			return .DCC_RL_KTXY_CHUNK_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			return unexpectedServerError(statusCode)
		default:
			return nil
		}
	}
	
	// MARK: - Private
	
	private func unexpectedServerError(
		_ statusCode: Int
	) -> KIDTypeChunkResourceError? {
		switch statusCode {
		case (400...499):
			return .DCC_RL_KTXY_CHUNK_CLIENT_ERROR
		case (500...599):
			return .DCC_RL_KTXY_CHUNK_SERVER_ERROR
		default:
			return nil
		}
	}
}
