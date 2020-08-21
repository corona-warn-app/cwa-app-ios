//
// Corona-Warn-App
//
// SAP SE and all other contributors /
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import CommonCrypto
import CryptoKit

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
		func reject() { completionHandler(.cancelAuthenticationChallenge, /* credential */ nil) }

		// `serverTrust` not nil implies that authenticationMethod == NSURLAuthenticationMethodServerTrust
		guard
			let trust = challenge.protectionSpace.serverTrust
		else {
			// Reject all requests that we do not have a public key to pin for
			reject()
			return
		}

		let localPublicKey = self.localPublicKey

		// We discard the returned status code (OSStatus) because this is also how
		// Apple is doing it in their official sample code – see [0] for more info.
		SecTrustEvaluateAsyncWithError(trust, .main) { trust, isValid, error in
			func accept() { completionHandler(.useCredential, URLCredential(trust: trust)) }

			guard isValid else {
				logError(message: "Server certificate is not valid. Rejecting challenge!")
				reject()
				return
			}

			guard error == nil else {
				logError(message: "Encountered error when evaluating server trust challenge, rejecting!")
				reject()
				return
			}

			// Our landscape has a certificate chain with three certificates.
			// We want to get the intermediate certificate, in our case the second.
			guard
				SecTrustGetCertificateCount(trust) >= 2,
				SecTrustEvaluateWithError(trust, nil),
				let remoteCertificate = SecTrustGetCertificateAtIndex(trust, 1)
			else {
				logError(message: "Could not trust or get certificate, rejecting!")
				reject()
				return
			}

			guard
				let remotePublicKey = SecCertificateCopyKey(remoteCertificate),
				let remotePublicKeyData = SecKeyCopyExternalRepresentation(remotePublicKey, nil) as Data?
			else {
				logError(message: "Failed to get the remote server's public key!")
				reject()
				return
			}

			let hashedRemotePublicKey = self.sha256ForRSA2048(data: remotePublicKeyData)
			// We simply compare the two hashed keys, and reject the challenge if they do not match
			guard hashedRemotePublicKey == localPublicKey else {
				logError(message: "The server's public key did not match what we expected!")
				reject()
				return
			}

			accept()
		}
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

		let hash = SHA256.hash(data: keyWithHeader)
		return Data(hash).base64EncodedString()
	}
}
