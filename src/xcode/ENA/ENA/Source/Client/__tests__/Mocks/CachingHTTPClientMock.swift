//
// 🦠 Corona-Warn-App
//

import Foundation

#if DEBUG
final class CachingHTTPClientMock: CachingHTTPClient {

	convenience init(environemntProvider: EnvironmentProviding = Environments()) {
		self.init(environmentProvider: environemntProvider)
	}

	static let staticAppConfig = SAP_Internal_V2_ApplicationConfigurationIOS()

	static let staticStatistics: SAP_Internal_Stats_Statistics = {
		guard
			let url = Bundle(for: CachingHTTPClientMock.self).url(forResource: "sample_stats", withExtension: "bin"),
			let data = try? Data(contentsOf: url),
			let stats = try? SAP_Internal_Stats_Statistics(serializedData: data)
		else {
			fatalError("Cannot initialize static test data")
		}
		return stats
	}()
	
	static let staticQRCodeTemplate: SAP_Internal_Pt_QRCodePosterTemplateIOS = {
		guard
			let url = Bundle(for: CachingHTTPClientMock.self).url(forResource: "default_qr_code_poster_template_ios", withExtension: "bin"),
			let data = try? Data(contentsOf: url),
			let stats = try? SAP_Internal_Pt_QRCodePosterTemplateIOS(serializedData: data)
		else {
			fatalError("Cannot initialize static test data")
		}
		return stats
	}()

	static let staticAppConfigMetadata: AppConfigMetadata = {
		let bundle = Bundle(for: CachingHTTPClientMock.self)
		let configMetadata = AppConfigMetadata(lastAppConfigETag: "\"SomeETag\"", lastAppConfigFetch: .distantPast, appConfig: CachingHTTPClientMock.staticAppConfig)
		return configMetadata
	}()

	static let staticVaccinationValueSets: SAP_Internal_Dgc_ValueSets = {
		let bundle = Bundle(for: CachingHTTPClientMock.self)
		guard let configMetadata = try? SAP_Internal_Dgc_ValueSets(jsonString: "{\"vp\":{\"items\":[{\"key\":\"1119349007\",\"displayText\":\"SARS-CoV-2 mRNA vaccine\"}]},\"mp\":{\"items\":[{\"key\":\"EU/1/20/1528\",\"displayText\":\"Comirnaty\"}]},\"ma\":{\"items\":[{\"key\":\"ORG-100001699\",\"displayText\":\"AstraZeneca AB\"}]}}") else {
			fatalError("Cannot initialize static test data")
		}
		return configMetadata
	}()
	// MARK: - AppConfigurationFetching

	var onFetchAppConfiguration: ((String?, @escaping CachingHTTPClient.AppConfigResultHandler) -> Void)?

	override func fetchAppConfiguration(etag: String? = nil, completion: @escaping CachingHTTPClient.AppConfigResultHandler) {
		guard let handler = self.onFetchAppConfiguration else {
			let response = AppConfigurationFetchingResponse(CachingHTTPClientMock.staticAppConfig, "fake")
			completion((.success(response), nil))
			return
		}
		handler(etag, completion)
	}

	// MARK: - Statistics

	var onFetchStatistics: ((String?, @escaping CachingHTTPClient.StatisticsFetchingResultHandler) -> Void)?

	override func fetchStatistics(etag: String?, completion: @escaping CachingHTTPClient.StatisticsFetchingResultHandler) {
		guard let handler = self.onFetchStatistics else {
			let response = StatisticsFetchingResponse(CachingHTTPClientMock.staticStatistics, "fake")
			completion(.success(response))
			return
		}
		handler(etag, completion)
	}
	
	// MARK: - QRCodePosterTemplateFetching
	
	var onFetchQRCodePosterTemplateData: ((String?, @escaping CachingHTTPClient.QRCodePosterTemplateCompletionHandler) -> Void)?
		
	override func fetchQRCodePosterTemplateData(etag: String?, completion: @escaping CachingHTTPClient.QRCodePosterTemplateCompletionHandler) {
		guard let handler = self.onFetchQRCodePosterTemplateData else {
			let response = QRCodePosterTemplateResponse(CachingHTTPClientMock.staticQRCodeTemplate, "fake")
			completion(.success(response))
			return
		}
		handler(etag, completion)
	}
	
//	// MARK: - VaccinationValueSetsFetching
	
	var onFetchVaccinationValueSets: ((String?, @escaping CachingHTTPClient.VaccinationValueSetsCompletionHandler) -> Void)?
		
	override func fetchVaccinationValueSets(etag: String?, completion: @escaping CachingHTTPClient.VaccinationValueSetsCompletionHandler) {
		guard let handler = self.onFetchVaccinationValueSets else {
			let response = VaccinationValueSetsResponse(CachingHTTPClientMock.staticVaccinationValueSets, "fake")
			completion(.success(response))
			return
		}
		handler(etag, completion)
	}
}
#endif
