//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class OnBehalfCheckinSubmissionService {

	// MARK: - Init

	init(
		restServiceProvider: RestServiceProviding = .fake(),
		client: Client,
		appConfigurationProvider: AppConfigurationProviding
	) {
		#if DEBUG
		if isUITesting {
			self.client = ClientMock()
			self.appConfigurationProvider = CachedAppConfigurationMock()
			self.restServiceProvider = restServiceProvider

			return
		}
		#endif

		self.client = client
		self.appConfigurationProvider = appConfigurationProvider
		self.restServiceProvider = restServiceProvider
	}

	// MARK: - Internal

	func submit(
		checkin: Checkin,
		teleTAN: String,
		completion: @escaping (Result<Void, OnBehalfCheckinSubmissionError>) -> Void
	) {
		getRegistrationToken(
			for: teleTAN
		) { [weak self] result in
			switch result {
			case .success(let registrationToken):

				self?.getSubmissionTAN(
					registrationToken: registrationToken
				) { result in
					switch result {
					case .success(let submissionTAN):

						self?.submit(
							checkin: checkin,
							submissionTAN: submissionTAN,
							completion: { result in
								switch result {
								case .success:
									Log.info("[OnBehalfCheckinSubmissionService] Submission succeeded", log: .api)

									completion(.success(()))
								case .failure(let error):
									Log.error("[OnBehalfCheckinSubmissionService] Submission failed", log: .api, error: error)

									completion(.failure(.submissionError(error)))
								}
							}
						)
					case .failure(let error):
						Log.error("[OnBehalfCheckinSubmissionService] Getting submission TAN failed", log: .api, error: error)

						completion(.failure(.submissionTANError(error)))
					}
				}
			case .failure(let error):
				Log.error("[OnBehalfCheckinSubmissionService] Getting registration token failed", log: .api, error: error)

				completion(.failure(.registrationTokenError(error)))
			}
		}
	}

	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	private let client: Client
	private let appConfigurationProvider: AppConfigurationProviding

	private var subscriptions = Set<AnyCancellable>()

	private func getRegistrationToken(
		for tan: String,
		completion: @escaping (Result<String, ServiceError<TeleTanError>>) -> Void
	) {
		let resource = TeleTanResource(
			sendModel: KeyModel(
				key: tan,
				keyType: .teleTan,
				keyDob: nil
			)
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let model):
				completion(.success(model.registrationToken))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	private func getSubmissionTAN(
		registrationToken: String,
		completion: @escaping (Result<String, URLSession.Response.Failure>) -> Void
	) {
		client.getTANForExposureSubmit(
			forDevice: registrationToken,
			isFake: false,
			completion: completion
		)
	}

	private func submit(
		checkin: Checkin,
		submissionTAN: String,
		completion: @escaping (Result<Void, SubmissionError>) -> Void
	) {
		appConfigurationProvider
			.appConfiguration()
			.sink { [weak self] appConfig in
				guard let self = self else {
					return
				}

				let unencryptedCheckinsEnabled = self.appConfigurationProvider.featureProvider.value(for: .unencryptedCheckinsEnabled)

				var unencryptedCheckins = [SAP_Internal_Pt_CheckIn]()
				if unencryptedCheckinsEnabled {
					unencryptedCheckins = [checkin].preparedForSubmission(
						appConfig: appConfig,
						transmissionRiskLevelSource: .fixedValue(5)
					)
				}

				let checkinProtectedReports = [checkin].preparedProtectedReportsForSubmission(
					appConfig: appConfig,
					transmissionRiskLevelSource: .fixedValue(5)
				)

				self.client.submitOnBehalf(
					payload: SubmissionPayload(
						exposureKeys: [],
						visitedCountries: [],
						checkins: unencryptedCheckins,
						checkinProtectedReports: checkinProtectedReports,
						tan: submissionTAN,
						submissionType: .hostWarning
					),
					isFake: false
				) { result in
					completion(result)
				}

			}
			.store(in: &subscriptions)
	}

}
