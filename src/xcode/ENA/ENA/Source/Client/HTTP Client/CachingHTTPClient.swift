//
// 🦠 Corona-Warn-App
//

import Foundation

typealias StatisticsGroupIdentifier = String

class CachingHTTPClient: AppConfigurationFetching, StatisticsFetching, LocalStatisticsFetching, QRCodePosterTemplateFetching, VaccinationValueSetsFetching, DSCListFetching {

	private let environmentProvider: EnvironmentProviding

	enum CacheError: Error {
		case dataFetchError(message: String?)
		case dataVerificationError(message: String?)
	}

	/// The client configuration - mostly server endpoints per environment
	var configuration: HTTPClient.Configuration {
		HTTPClient.Configuration.makeDefaultConfiguration(
			environmentProvider: environmentProvider
		)
	}

	/// The underlying URLSession for all network requests
	let session: URLSession

	/// SignatureVerifier for the fetched & signed protobuf packages
	let signatureVerifier: SignatureVerifier

	/// Initializer for the caching client.
	///
	/// - Parameters:
	///   - clientConfiguration: The client configuration for the client.
	///   - session: An optional session to use for network requests. Default is based on a predefined configuration.
	///   - signatureVerifier: The signatureVerifier to use for package validation.
	init(
		environmentProvider: EnvironmentProviding = Environments(),
		session: URLSession = .coronaWarnSession(
			configuration: .cachingSessionConfiguration()
		),
		signatureVerifier: SignatureVerifier = SignatureVerifier()
	) {
		self.session = session
		self.environmentProvider = environmentProvider
		self.signatureVerifier = signatureVerifier
	}

	// MARK: - AppConfigurationFetching

	/// Fetches an application configuration file
	/// - Parameters:
	///   - etag: an optional ETag to download only versions that differ the given tag
	///   - completion: result handler
	func fetchAppConfiguration(
		etag: String? = nil,
		completion: @escaping AppConfigResultHandler
	) {
		// Manual ETagging because we don't use native cache
		var headers: [String: String]?
		if let etag = etag {
			headers = ["If-None-Match": etag]
		}

		session.GET(configuration.configurationURL, extraHeaders: headers) { result in
			switch result {
			case .success(let response):
				let serverDate = response.httpResponse.dateHeader

				// serialize config
				do {
					let package = try self.verifyPackage(in: response)
					let config = try SAP_Internal_V2_ApplicationConfigurationIOS(serializedData: package.bin)
					let eTag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let configurationResponse = AppConfigurationFetchingResponse(config, eTag)
					completion((.success(configurationResponse), serverDate))
				} catch {
					completion((.failure(error), serverDate))
				}
			case .failure(let error):
				var serverDate: Date?
				if case let .httpError(_, httpResponse) = error {
					serverDate = httpResponse.dateHeader
				}
				completion((.failure(error), serverDate))
			}
		}
	}

	// MARK: - StatisticsFetching

	/// Fetches statistics
	/// - Parameters:
	///   - etag: an optional ETag to download only versions that differ the given tag
	///   - completion: result handler
	func fetchStatistics(
		etag: String?,
		completion: @escaping StatisticsFetchingResultHandler
	) {
		// Manual ETagging because we don't use native cache
		var headers: [String: String]?
		if let etag = etag {
			headers = ["If-None-Match": etag]
		}

		session.GET(configuration.statisticsURL, extraHeaders: headers) { result in
			switch result {
			case .success(let response):
				do {
					let package = try self.verifyPackage(in: response)
					let stats = try SAP_Internal_Stats_Statistics(serializedData: package.bin)
					let responseETag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let configurationResponse = StatisticsFetchingResponse(stats, responseETag)
					completion(.success(configurationResponse))
				} catch {
					completion(.failure(error))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	// MARK: QRCodePosterTemplateFetching
	
	/// Fetches the QR Code Poster Template Protobuf
	/// - Parameters:
	/// - etag: an optional ETag to download only versions that differ the given tag
	/// - completion: The completion handler of the get call, which contains the prootbuf response
	func fetchQRCodePosterTemplateData(
		etag: String?,
		completion: @escaping QRCodePosterTemplateCompletionHandler
	) {
		// Manual ETagging because we don't use native cache
		var headers: [String: String]?
		if let etag = etag {
			headers = ["If-None-Match": etag]
		}

		session.GET(configuration.qrCodePosterTemplateURL, extraHeaders: headers) { result in
			switch result {
			case .success(let response):
				do {
					let package = try self.verifyPackage(in: response)
					let qrCodePosterTemplateData = try SAP_Internal_Pt_QRCodePosterTemplateIOS(serializedData: package.bin)
					let responseETag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let qrCodePosterResponse = QRCodePosterTemplateResponse(qrCodePosterTemplateData, responseETag)
					completion(.success(qrCodePosterResponse))
				} catch {
					completion(.failure(error))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	// MARK: VaccinationValueSetsFetching
	
	/// Fetches vaccination value sets
	/// - Parameters:
	///   - etag: an optional ETag to download only versions that differ the given tag
	///   - completion: result handler
	func fetchVaccinationValueSets(
		etag: String?,
		completion: @escaping VaccinationValueSetsCompletionHandler
	) {
		// Manual ETagging because we don't use native cache
		var headers: [String: String]?
		if let etag = etag {
			headers = ["If-None-Match": etag]
		}

		session.GET(configuration.vaccinationValueSetsURL, extraHeaders: headers) { result in
			switch result {
			case let .success(response):
				do {
					let package = try self.verifyPackage(in: response)
					let vaccinationValueSetsData = try SAP_Internal_Dgc_ValueSets(serializedData: package.bin)
					let responseETag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let vaccinationValueSetsResponse = VaccinationValueSetsResponse(vaccinationValueSetsData, responseETag)
					Log.info("Received value sets: \(try vaccinationValueSetsData.jsonString())", log: .vaccination)
					completion(.success(vaccinationValueSetsResponse))
				} catch {
					completion(.failure(error))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	// MARK: Protocol DSCListFetching

	/// Fetches lis of DSC certificates
	/// - Parameters:
	///   - etag: an optional ETag to download only versions that differ the given tag
	///   - completion: result handler
	func fetchDSCList(
		etag: String?,
		completion: @escaping DSCListCompletionHandler
	) {
		// Manual ETagging because we don't use native cache
		var headers: [String: String]?
		if let etag = etag {
			headers = ["If-None-Match": etag]
		}

		session.GET(configuration.DSCListURL, extraHeaders: headers) { result in
			switch result {
			case let .success(response):
				do {
					let package = try self.verifyPackage(in: response)
					let DSCList = try SAP_Internal_Dgc_DscList(serializedData: package.bin)
					let responseETag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let dscListResponse = DSCListResponse(dscList: DSCList, eTag: responseETag)
					Log.info("Received DSCList \(try DSCList.jsonString())", log: .vaccination)
					completion(.success(dscListResponse))
				} catch URLSessionError.notModified {
					Log.error("Server not modified since last update", log: .api)
					completion(.failure(URLSessionError.notModified))
				} catch {
					Log.error("Failed to unpack / parse data from the response to expected data structure", log: .api)
					completion(.failure(error))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	// MARK: LocalStatisticsFetching
	
	/// Fetches local statistics
	/// - Parameters:
	///   - groupID: string to pass group ID to the API to get local statistics
	///   - etag: an optional ETag to download only versions that differ the given tag
	///   - completion: result handler
	func fetchLocalStatistics(
		groupID: StatisticsGroupIdentifier,
		eTag: String?,
		completion: @escaping LocalStatisticsCompletionHandler
	) {
		// Manual ETagging because we don't use native cache
		var headers: [String: String]?
		if let eTag = eTag {
			headers = ["If-None-Match": eTag]
		}

		let url = configuration.localStatisticsURL(groupID: groupID)
		session.GET(url, extraHeaders: headers) { result in
			switch result {
			case .success(let response):
				do {
					let package = try self.verifyPackage(in: response)
					let localStatistics = try SAP_Internal_Stats_LocalStatistics(serializedData: package.bin)
					let responseETag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let localStatisticsResponse = LocalStatisticsResponse(localStatistics, responseETag, groupID)
					completion(.success(localStatisticsResponse))
				} catch {
					completion(.failure(error))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	// MARK: - Helpers

	private func verifyPackage(in response: URLSession.Response) throws -> SAPDownloadedPackage {
		// content not modified?
		guard response.statusCode != 304 else {
			throw URLSessionError.notModified
		}

		// has data?
		guard
			let data = response.body,
			let package = SAPDownloadedPackage(compressedData: data)
		else {
			let error = CacheError.dataFetchError(message: "Failed to create downloaded package.")
			throw error
		}

		// data verified?
		guard self.signatureVerifier(package) else {
			let error = CacheError.dataVerificationError(message: "Failed to verify signature.")
			throw error
		}

		return package
	}
}
