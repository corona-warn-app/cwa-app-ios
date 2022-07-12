//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class OnBehalfCheckinSubmissionService {

	// MARK: - Init

	init(
		restServiceProvider: RestServiceProviding,
		appConfigurationProvider: AppConfigurationProviding
	) {
		#if DEBUG
		if isUITesting {
			self.appConfigurationProvider = CachedAppConfigurationMock()
			self.restServiceProvider = .onBehalfCheckinSubmissionServiceProviderStub

			return
		}
		#endif

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

						completion(.failure(.registrationTokenError(error)))
					}
				}
			case .failure(let error):
				Log.error("[OnBehalfCheckinSubmissionService] Getting registration token failed", log: .api, error: error)

				completion(.failure(.teleTanError(error)))
			}
		}
	}

	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	private let appConfigurationProvider: AppConfigurationProviding

	private var subscriptions = Set<AnyCancellable>()

	private func getRegistrationToken(
		for tan: String,
		completion: @escaping (Result<String, ServiceError<TeleTanError>>) -> Void
	) {
		let resource = TeleTanResource(
			sendModel: TeleTanSendModel(
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
		completion: @escaping (Result<String, ServiceError<RegistrationTokenError>>) -> Void
	) {
		let resource = RegistrationTokenResource(
			sendModel: RegistrationTokenSendModel(
				token: registrationToken
			)
		)
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let model):
				completion(.success(model.submissionTAN))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	private func submit(
		checkin: Checkin,
		submissionTAN: String,
		completion: @escaping (Result<Void, ServiceError<OnBehalfSubmissionResourceError>>) -> Void
	) {
		appConfigurationProvider
			.appConfiguration()
			.sink { [weak self] appConfig in
				guard let self = self else {
					return
				}

				let unencryptedCheckinsEnabled = self.appConfigurationProvider.featureProvider.boolValue(for: .unencryptedCheckinsEnabled)

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
				
				let resource = OnBehalfSubmissionResource(
					payload: SubmissionPayload(
						exposureKeys: [],
						visitedCountries: [],
						checkins: unencryptedCheckins,
						checkinProtectedReports: checkinProtectedReports,
						tan: submissionTAN,
						submissionType: .hostWarning
					)
				)
				
				self.restServiceProvider.load(resource) { result in
					let voidResult = result.flatMap { _ in
						Result.success(())
					}
					completion(voidResult)
				}

			}
			.store(in: &subscriptions)
	}

}
