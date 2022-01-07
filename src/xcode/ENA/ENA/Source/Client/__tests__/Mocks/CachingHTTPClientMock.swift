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
			let url = Bundle(for: CachingHTTPClientMock.self).url(forResource: "stats", withExtension: "bin"),
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
		let jsonString = "{\"vp\":{\"items\":[{\"key\":\"1119349007\",\"displayText\":\"SARS-CoV-2 mRNA vaccine\"}]},\"mp\":{\"items\":[{\"key\":\"EU/1/20/1507\",\"displayText\":\"BionTech\"}]},\"ma\":{\"items\":[{\"key\":\"ORG-100031184\",\"displayText\":\"Pfizer\"}]},\"tg\":{\"items\":[{\"key\":\"840539006\",\"displayText\":\"COVID-19\"}]},\"tcTt\":{\"items\":[{\"key\":\"LP6464-4\",\"displayText\":\"Rapid Antigen Test\"}]},\"tcTr\":{\"items\":[{\"key\":\"260415000\",\"displayText\":\"Negative\"}]}}"
		guard let configMetadata = try? SAP_Internal_Dgc_ValueSets(jsonString: jsonString) else {
			fatalError("Cannot initialize static test data")
		}
		return configMetadata
	}()
	
	static let staticLocalStatistics: SAP_Internal_Stats_LocalStatistics = {
		guard
			let url = Bundle(for: CachingHTTPClientMock.self).url(forResource: "LocalStats", withExtension: "bin"),
			let data = try? Data(contentsOf: url),
			let localStatistics = try? SAP_Internal_Stats_LocalStatistics(serializedData: data)
		else {
			Log.debug("Cannot initialize static test data", log: .localStatistics)
			return SAP_Internal_Stats_LocalStatistics()
		}
		return localStatistics
	}()
	
	// MARK: - AppConfigurationFetching

	var onFetchAppConfiguration: ((String?, @escaping CachingHTTPClient.AppConfigResultHandler) -> Void)?

	override func fetchAppConfiguration(etag: String? = nil, completion: @escaping CachingHTTPClient.AppConfigResultHandler) {
		let clientQueue = DispatchQueue(label: "ClientQueue", attributes: .concurrent)

		guard let handler = self.onFetchAppConfiguration else {
			let response = AppConfigurationFetchingResponse(CachingHTTPClientMock.staticAppConfig, "fake")
			// Dispatch the completion call to simulate URLSession calling back on another thread.
			clientQueue.async {
				completion((.success(response), nil))
			}
			return
		}
		
		// Dispatch the completion call to simulate URLSession calling back on another thread.
		clientQueue.async {
			handler(etag, completion)
		}
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
	
	// MARK: - VaccinationValueSetsFetching
	
	var onFetchVaccinationValueSets: ((String?, @escaping CachingHTTPClient.VaccinationValueSetsCompletionHandler) -> Void)?
		
	override func fetchVaccinationValueSets(etag: String?, completion: @escaping CachingHTTPClient.VaccinationValueSetsCompletionHandler) {
		guard let handler = self.onFetchVaccinationValueSets else {
			let response = VaccinationValueSetsResponse(CachingHTTPClientMock.staticVaccinationValueSets, "fake")
			completion(.success(response))
			return
		}
		handler(etag, completion)
	}
	
	// MARK: - LocalStatisticsFetching
	
	var onFetchLocalStatistics: ((String?, @escaping CachingHTTPClient.LocalStatisticsCompletionHandler) -> Void)?
		
	override func fetchLocalStatistics(groupID: StatisticsGroupIdentifier, eTag: String?, completion: @escaping CachingHTTPClient.LocalStatisticsCompletionHandler) {
		guard let handler = self.onFetchLocalStatistics else {
			let response = LocalStatisticsResponse(CachingHTTPClientMock.staticLocalStatistics, "fake", "1")
			completion(.success(response))
			return
		}
		handler(eTag, completion)
	}

	// MARK: Protocol DSCListFetching

	static let staticDSCList: SAP_Internal_Dgc_DscList = {
		guard
			let url = Bundle(for: CachingHTTPClientMock.self).url(forResource: "default_dsc_list", withExtension: "bin"),
			let data = try? Data(contentsOf: url),
			let dscList = try? SAP_Internal_Dgc_DscList(serializedData: data)
		else {
			Log.debug("Cannot initialize static test data", log: .vaccination)
			return SAP_Internal_Dgc_DscList()
		}
		return dscList
	}()

	var onFetchLocalDSCList: ((String?, @escaping CachingHTTPClient.DSCListCompletionHandler) -> Void)?

	override func fetchDSCList(
		etag: String?,
		completion: @escaping DSCListCompletionHandler
	) {
		guard let handler = self.onFetchLocalDSCList else {
			let response = DSCListResponse(dscList: CachingHTTPClientMock.staticDSCList, eTag: "fake")
			completion(.success(response))
			return
		}
		handler(etag, completion)
	}

}
#endif
