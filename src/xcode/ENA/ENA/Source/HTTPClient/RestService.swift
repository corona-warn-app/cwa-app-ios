//
// 🦠 Corona-Warn-App
//

import Foundation

/// this service can communicate with a rest server
///
class RestService {

	// MARK: - Init

	init(
		session: URLSession = URLSession(configuration: .coronaWarnSessionConfiguration()),
		environment: EnvironmentProviding = Environments()
	) {
		self.session = session
		self.environment = environment
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	enum ServiceError: Error {
		case serverError(Error?)
		case unexpectedResponse(Int)
		case decodeError
	}

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: HTTPResource {
		
		let request = URLRequest(url: createURL(for: resource.resourceLocator))
		session.dataTask(with: request) { bodyData, response, error in
			guard error == nil,
				  let urlResponse = response as? HTTPURLResponse else {
				Log.debug("Error: \(error?.localizedDescription ?? "no reason given")", log: .client)
				completion(.failure(.serverError(error)))
				return
			}
			#if DEBUG
			Log.debug("URL Response \(urlResponse.statusCode)", log: .client)
			#endif
			switch urlResponse.statusCode {
			case 200:
				switch resource.decode(bodyData) {
				case .success(let model):
					completion(.success(model))
				case .failure:
					completion(.failure(.decodeError))
				}
			case 201...204:
				completion(.success(nil))

			// handle error / notModified cases here

			default:
				completion(.failure(.unexpectedResponse(urlResponse.statusCode)))
			}
		}.resume()
	}

	// MARK: - Private

	private let session: URLSession
	private let environment: EnvironmentProviding
		
	private func createURL(for locator: ResourceLocator) -> URL {
		let endpointUrl = endpointUrl(for: locator.endpoint)
		let url = locator.paths.reduce(endpointUrl) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		return url
	}
	
	private func endpointUrl(for endpoint: Endpoint) -> URL {
		switch endpoint {
		case .distribution:
			return environment.currentEnvironment().distributionURL
		case .submission:
			return environment.currentEnvironment().submissionURL
		case .verification:
			return environment.currentEnvironment().verificationURL
		case .errorLogSubmission:
			return environment.currentEnvironment().errorLogSubmissionURL
		case .dcc:
			return environment.currentEnvironment().dccURL
		case .dataDonation:
			return environment.currentEnvironment().dataDonationURL
		}
	}
}


struct RestServiceTest {

	func load() {
		let restService = RestService()
		let locator = ResourceLocator.appConfiguration(eTag: "FakeETag")

		let configuration = ProtobufResource<SAP_Internal_V2_ApplicationConfigurationIOS>(resourceLocator: locator)
//		let url = configuration.url(with: parameters)
//		let url2 = URL.appConfig(parameters)

//		let jsonResource = JSONResource<String>(url: URL(staticString: "http://www.test.de"), method: .get)
		restService.load(resource: configuration) { result in
			if case let .success(model) = result {
				Log.debug("did load some model data \(String(describing: model))")
			}
		}

	}
}
