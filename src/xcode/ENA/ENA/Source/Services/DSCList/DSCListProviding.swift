////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol DSCListProviding {
	/// Proofs before fetching if we have cached something and returns this. Otherwise, it fetches from server. If the server returns 304 (not modified), we take again the cached DSC list and return them.
	func latestDSCList() -> AnyPublisher<SAP_Internal_Dgc_DscList, Error>
	/// Fetches every time from server regardless of something cached. If the server returns 304 (not modified), we take again the cached DSC list and return them.
	func fetchDSCList() -> AnyPublisher<SAP_Internal_Dgc_DscList, Error>
}

protocol DSCListFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }

	typealias DSCListCompletionHandler = (Result<DSCListResponse, Error>) -> Void

	func getDSCList(etag: String?, completion: @escaping DSCListCompletionHandler)

}

struct DSCListResponse {
	let DSCList: SAP_Internal_Dgc_DscList
	let eTag: String?
}
