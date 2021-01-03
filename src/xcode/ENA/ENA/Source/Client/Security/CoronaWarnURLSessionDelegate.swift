//
// 🦠 Corona-Warn-App
//

import Foundation

final class CoronaWarnURLSessionDelegate: NSObject {
	private let publicKeyHash: String

	// MARK: - Creating a Delegate


	/// Initializes a CWA Session delegate
	/// - Parameter publicKeyHash: the SHA256 of the certificate to pin
	init(publicKeyHash: String) {
		self.publicKeyHash = publicKeyHash
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
				if let cert = SecTrustGetCertificateAtIndex(trust, i) {
					Log.debug("[\(challenge.protectionSpace.host)] @ \(i): \(cert)", log: .crypto)
				}
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
				if publicKeyHash == keyHash {
					// Success! This is our server
					completionHandler(.useCredential, URLCredential(trust: trust))
					return
				}
			}
		}

		completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
	}
}
