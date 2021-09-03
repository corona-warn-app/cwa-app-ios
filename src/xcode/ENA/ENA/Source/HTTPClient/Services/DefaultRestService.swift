//
// 🦠 Corona-Warn-App
//

import Foundation

class DefaultRestService: Service {

	// MARK: - Init

	required init(
		environment: EnvironmentProviding = Environments()
	) {
		self.environment = environment
	}

	// MARK: - Overrides

	// MARK: - Protocol Service

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: Resource {
		let request = resource.locator.urlRequest(environmentData: environment.currentEnvironment())
		// TODO: add headers is missing
		session.dataTask(with: request) { bodyData, response, error in
			
			// TODO: special handling: UserDefaults.standard.dmLastSubmissionRequest = request.httpBody
			// TODO: special handling:UserDefaults.standard.dmLastOnBehalfCheckinSubmissionRequest = request.httpBody

			guard error == nil,
				  let response = response as? HTTPURLResponse else {
				Log.debug("Error: \(error?.localizedDescription ?? "no reason given")", log: .client)
				completion(.failure(.serverError(error)))
				return
			}
			
			// TODO: Handling for noNetwork:
			/*
			if let error = error as NSError?,
			   error.domain == NSURLErrorDomain,
			   error.code == NSURLErrorNotConnectedToInternet {
				Log.error("No network connection", log: .api, error: error)
				completion(.failure(.noNetworkConnection))
				return
			}
			*/
			
			
			#if DEBUG
			Log.debug("URL Response \(response.statusCode)", log: .client)
			#endif
			switch response.statusCode {
			// TODO: special case response.hasAcceptableStatusCode -> 200...299
			// TODO special case submitPPA: only success for 204, NOT for 200
			case 200:
				switch resource.decode(bodyData) {
				case .success(let model):
					completion(.success(model))
				case .failure:
					completion(.failure(.decodeError))
				}
			case 201...204:
				completion(.success(nil))

			case 304:
				completion(.failure(.notModified))
				
			// TODO:
			//case 400:
			// special handling for registrationTokenResponse
			// special handling for getTestResult
			// special handling for getTANForExposureSubmit
			// special handling for submissionKeys
			// special handling for submitOnBehalf
			// special handling for authorizeOTPEdus
			// special handling for authorizeOTPEls
			// special handling for submitPPA
			
			// TODO:
			//case 401:
			// special handling for authorizeOTPEdus
			// special handling for authorizeOTPEls
			// special handling for submitPPA
			
			// TODO:
			//case 403:
			// special handling for submissionKeys
			// special handling for submitOnBehalf
			// special handling for authorizeOTPEdus
			// special handling for authorizeOTPEls
			// special handling for submitPPA
			
			// TODO:
			//case 429:
			// special handling for authorizeOTPEdus
			// special handling for submitPPA

			// TODO:
			//case 500:
			// special handling for authorizeOTPEdus
			// special handling for authorizeOTPEls
			// special handling for submitPPA
			
			// handle error / notModified cases here

			default:
				completion(.failure(.unexpectedResponse(response.statusCode)))
			}
		}.resume()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private lazy var session: URLSession = {
		URLSession(configuration: .coronaWarnSessionConfiguration())
	}()

	private let environment: EnvironmentProviding
}
