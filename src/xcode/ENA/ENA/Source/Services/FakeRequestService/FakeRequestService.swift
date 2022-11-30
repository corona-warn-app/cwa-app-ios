////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class FakeRequestService {

	// MARK: - Init

	init(
		restServiceProvider: RestServiceProviding,
		ppacService: PrivacyPreservingAccessControl
	) {
		self.restServiceProvider = restServiceProvider
		self.ppacService = ppacService
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
	func fakeRequest(completion: (() -> Void)? = nil) {
		fakeVerificationServerRequest {
			self.fakeVerificationServerRequest {
				self.fakeSubmissionServerRequest {
					completion?()
				}
			}
		}
	}

	/// This method represents a dummy method that is sent to the verification server.
	func fakeVerificationServerRequest(completion: (() -> Void)? = nil) {
		let resource = RegistrationTokenResource(
			isFake: true,
			sendModel: RegistrationTokenSendModel(
				token: Self.fakeRegistrationToken
			)
		)
		restServiceProvider.load(resource) { _ in
			completion?()
		}
	}

	/// This method represents a dummy method that is sent to the submission server.
	func fakeSubmissionServerRequest(completion: (() -> Void)? = nil) {
		let payload = SubmissionPayload(
			exposureKeys: [],
			visitedCountries: [],
			checkins: [],
			checkinProtectedReports: [],
			tan: Self.fakeSubmissionTan,
			submissionType: SAP_Internal_SubmissionPayload.SubmissionType(
				rawValue: Int.random(in: 0...1)
			) ?? .pcrTest
		)
		
		let resource = KeySubmissionResource(
			payload: payload,
			isFake: true
		)
		restServiceProvider.load(resource) { _ in
			completion?()
		}
	}

	/// This method represents the fake Request for SRS OTP
	func fakeSRSOTPServerRequest(completion: (() -> Void)? = nil) {
		self.ppacService.getPPACTokenSRS { [weak self] result in
			guard let self = self else {
				Log.warning("[FakeRequestService] Could not get self, skipping fakeSRSOTPServerRequest call")
				completion?()
				return
			}
			
			switch result {
			case let .success(ppacToken):
				let resource = OTPAuthorizationForSRSResource(
					// no need to inject otpService as it can be generated easily
					otpSRS: UUID().uuidString,
					isFake: true,
					ppacToken: ppacToken
				)
				self.restServiceProvider.load(resource) { _ in
					completion?()
				}
			case .failure:
				Log.warning("[FakeRequestService] Could not get PPAC token for SRS, skipping fakeSRSOTPServerRequest call")
				completion?()
			}
		}
	}
		
	/// This method is convenience for sending a V + S request pattern.
	func fakeVerificationAndSubmissionServerRequest(completion: (() -> Void)? = nil) {
		fakeVerificationServerRequest { [weak self] in
			guard let self = self else {
				Log.warning("[FakeRequestService] Could not get self, skipping fakeSubmissionServerRequest call")
				completion?()
				return
			}
			
			self.fakeSubmissionServerRequest {
				completion?()
			}
		}
	}

	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	private let ppacService: PrivacyPreservingAccessControl
}
