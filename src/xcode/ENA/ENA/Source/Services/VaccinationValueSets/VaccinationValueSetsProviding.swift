//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol VaccinationValueSetsProviding: AnyObject {
	func latestVaccinationCertificateValueSets(with etag: String?) -> AnyPublisher<SAP_Internal_Dgc_ValueSets, Error>
}

protocol VaccinationValueSetsFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var signatureVerifier: SignatureVerifier { get }

	typealias VaccinationValueSetsCompletionHandler = (Result<VaccinationValueSetsResponse, Error>) -> Void

	func fetchVaccinationValueSets(
		etag: String?,
		completion: @escaping (Result<VaccinationValueSetsResponse, Error>) -> Void
	)
}

struct VaccinationValueSetsResponse {
	let valueSets: SAP_Internal_Dgc_ValueSets
	let eTag: String?
	let timestamp: Date

	init(_ config: SAP_Internal_Dgc_ValueSets, _ eTag: String? = nil) {
		self.valueSets = config
		self.eTag = eTag
		self.timestamp = Date()
	}
}
