////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class FakeRequestService {

	// MARK: - Init

	init(
		client: Client
	) {
		self.client = client
	}

	// MARK: - Internal

	enum FakeError: Error {
		case fakeResponse
	}

	static let fakeRegistrationToken = "63b4d3ff-e0de-4bd4-90c1-17c2bb683a2f"
	static var fakeSubmissionTan: String { return UUID().uuidString }

	/// This method is called randomly sometimes in the foreground and from the background.
	/// It represents the full-fledged dummy request needed to realize plausible deniability.
	/// Nothing called in this method is considered a "real" request.
	func fakeRequest(completionHandler: ((_ error: ExposureSubmissionError?) -> Void)? = nil) {
		fakeVerificationServerRequest { _ in
			self.fakeVerificationServerRequest(completion: { _ in
				self.fakeSubmissionServerRequest(completion: { _ in
					completionHandler?(.fakeResponse)
				})
			})
		}
	}

	/// This method represents a dummy method that is sent to the verification server.
	func fakeVerificationServerRequest(completion completeWith: @escaping (Result<String, FakeError>) -> Void) {
		client.getTANForExposureSubmit(forDevice: Self.fakeRegistrationToken, isFake: true) { _ in
			completeWith(.failure(.fakeResponse))
		}
	}

	/// This method represents a dummy method that is sent to the submission server.
	func fakeSubmissionServerRequest(completion: @escaping (_ error: ExposureSubmissionError?) -> Void) {
		let payload = CountrySubmissionPayload(
			exposureKeys: [],
			visitedCountries: [],
			tan: Self.fakeSubmissionTan
		)

		client.submit(payload: payload, isFake: true) { _ in
			completion(.fakeResponse)
		}
	}

	/// This method is convenience for sending a V + S request pattern.
	func fakeVerificationAndSubmissionServerRequest(completionHandler: ((_ error: ExposureSubmissionError?) -> Void)? = nil) {
		fakeVerificationServerRequest { _ in
			self.fakeSubmissionServerRequest { _ in
				completionHandler?(.fakeResponse)
			}
		}
	}

	// MARK: - Private

	private let client: Client

}
