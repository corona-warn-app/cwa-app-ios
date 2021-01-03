//
// 🦠 Corona-Warn-App
//

import Foundation

final class CoronaWarnURLSessionDelegate: NSObject {
	private let localPublicKey: String

	// MARK: Creating a Delegate
	init(localPublicKey: String) {
		self.localPublicKey = localPublicKey
	}
}

extension CoronaWarnURLSessionDelegate: URLSessionDelegate {
	func urlSession(
		_ session: URLSession,
		didReceive challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	) {
		// `serverTrust` not nil implies that authenticationMethod == NSURLAuthenticationMethodServerTrust
		guard let trust = challenge.protectionSpace.serverTrust else {
			// Reject all requests that we do not have a public key to pin for
			completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
			return
		}

		var secresult = SecTrustResultType.invalid
		let status = SecTrustEvaluate(trust, &secresult)

		if status == errSecSuccess {
			#if DEBUG
			// debug/review: print the chain
			for i in 0..<SecTrustGetCertificateCount(trust) {
				let cert = SecTrustGetCertificateAtIndex(trust, i)
				Log.debug("[\(challenge.protectionSpace.host)] @ \(i): \(cert.debugDescription)", log: .api)
			}
			#endif

			// we expect a chain of at least 2 certificates
			// index '1' is the required intermediate
			if
				let serverCertificate = SecTrustGetCertificateAtIndex(trust, 1),
				let serverPublicKey = SecCertificateCopyKey(serverCertificate),
				let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil ) as Data? {

				// Matching fingerprint?
				let keyHash = serverPublicKeyData.sha256String()
				if localPublicKey == keyHash {
					// Success! This is our server
					completionHandler(.useCredential, URLCredential(trust: trust))
					return
				}
			}
		}

		completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
	}
}

// [0] https://developer.apple.com/documentation/security/certificate_key_and_trust_services/trust/evaluating_a_trust_and_parsing_the_result

extension CoronaWarnURLSessionDelegate {
	var rsa2048Asn1HeaderBytes: [UInt8] { [
		0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09,
		0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
		0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
	] }

	private func sha256ForRSA2048(data: Data) -> String {
		var keyWithHeader = Data(rsa2048Asn1HeaderBytes)
		keyWithHeader.append(data)

		let hash = keyWithHeader.sha256()
		return Data(hash).base64EncodedString()
	}
}
