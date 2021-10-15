//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

protocol DSCListProviding {
	var signingCertificates: CurrentValueSubject<[DCCSigningCertificate], Never> { get }
}

protocol DSCListFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var signatureVerifier: SignatureVerifier { get }
	
	typealias DSCListCompletionHandler = (Result<DSCListResponse, Error>) -> Void

	func fetchDSCList(etag: String?, completion: @escaping DSCListCompletionHandler)
}

struct DSCListResponse {
	let dscList: SAP_Internal_Dgc_DscList
	let eTag: String?
}
