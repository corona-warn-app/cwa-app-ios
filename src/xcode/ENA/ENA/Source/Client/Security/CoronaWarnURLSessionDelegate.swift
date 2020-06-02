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

final class CoronaWarnURLSessionDelegate: NSObject {
	// MARK: Creating a Delegate
	init(certificateData: Data) {
		precondition(
			!certificateData.isEmpty,
			"Certificate pinning requires a data blob that at least looks like a valid certificate."
		)
		self.certificateData = certificateData
	}

	// MARK: Properties
	private let certificateData: Data
}

extension CoronaWarnURLSessionDelegate: URLSessionDelegate {
	func urlSession(
		_ session: URLSession,
		didReceive challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	) {
		func reject() { completionHandler(.cancelAuthenticationChallenge, /* credential */ nil) }

		// `serverTrust` not nil implies that authenticationMethod == NSURLAuthenticationMethodServerTrust
		guard let trust = challenge.protectionSpace.serverTrust else {
			reject()
			return
		}

		// We discard the returned status code (OSStatus) because this is also how
		// Apple is doing it in their official sample code – see [0] for more info.
		SecTrustEvaluateAsyncWithError(trust, .main) { trust, isValid, error in
			func accept() { completionHandler(.useCredential, URLCredential(trust: trust)) }

			guard isValid else {
				reject()
				return
			}

			guard error == nil else {
				reject()
				return
			}

			guard SecTrustGetCertificateCount(trust) >= 1 else {
				reject()
				return
			}

			guard let remoteCertificate = SecTrustGetCertificateAtIndex(trust, 0) else {
				reject()
				return
			}

			let remoteCertificateData = SecCertificateCopyData(remoteCertificate) as Data
			guard remoteCertificateData == self.certificateData else {
				reject()
				return
			}

			accept()
		}
	}
}

// [0] https://developer.apple.com/documentation/security/certificate_key_and_trust_services/trust/evaluating_a_trust_and_parsing_the_result
