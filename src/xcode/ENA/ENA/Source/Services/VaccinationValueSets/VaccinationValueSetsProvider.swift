//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class VaccinationValueSetsProvider: VaccinationValueSetsProviding {

	// MARK: - Init

	init(client: VaccinationValueSetsFetching, store: Store) {
		self.client = client
		self.store = store
	}

	// MARK: - Internal

	func latestVaccinationCertificateValueSets() -> AnyPublisher<SAP_Internal_Dgc_ValueSets, Error> {
		let etag = store.vaccinationCertificateValueDataSets?.lastValueDataSetsETag

		guard let cached = store.vaccinationCertificateValueDataSets, !shouldFetch() else {
			return fetchVaccinationValueSets(with: etag).eraseToAnyPublisher()
		}
		// return cached data; no error
		return Just(cached.valueDataSets)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	// MARK: - Private

	private let client: VaccinationValueSetsFetching
	private let store: Store

	private func fetchVaccinationValueSets(with etag: String? = nil) -> Future<SAP_Internal_Dgc_ValueSets, Error> {
		return Future { promise in
			self.client.fetchVaccinationValueSets(etag: etag) { result in
				switch result {
				case .success(let response):
					// cache
					self.store.vaccinationCertificateValueDataSets = VaccinationValueDataSets(with: response)
					promise(.success(response.valueSets))
				case .failure(let error):
					Log.error(error.localizedDescription, log: .vaccination)
					switch error {
					case URLSessionError.notModified:
						self.store.vaccinationCertificateValueDataSets?.refreshLastVaccinationValueDataSetsFetchDate()
					default:
						break
					}
					// return cached if it exists
					if let cachedValuesSets = self.store.vaccinationCertificateValueDataSets {
						promise(.success(cachedValuesSets.valueDataSets))
					} else {
						promise(.failure(error))
					}
				}
			}
		}
	}

	private func shouldFetch() -> Bool {
		if store.vaccinationCertificateValueDataSets == nil { return true }

		// naive cache control
		guard let lastFetch = store.vaccinationCertificateValueDataSets?.lastValueDataSetsFetchDate else {
			return true
		}
		Log.debug("timestamp >= 300s? \(abs(Date().timeIntervalSince(lastFetch))) >= 300)", log: .vaccination)
		return abs(Date().timeIntervalSince(lastFetch)) >= 300
	}
}
