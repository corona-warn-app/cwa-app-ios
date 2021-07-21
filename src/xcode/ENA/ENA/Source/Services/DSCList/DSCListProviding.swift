//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol DSCListProviding {

	var lastUpdate: CurrentValueSubject<DSCListMetaData, Never> { get }
	var dscList: SAP_Internal_Dgc_DscList { get }

}

protocol DSCListFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }

	typealias DSCListCompletionHandler = (Result<DSCListResponse, Error>) -> Void

	func fetchDSCList(etag: String?, completion: @escaping DSCListCompletionHandler)

}

struct DSCListResponse {
	let dscList: SAP_Internal_Dgc_DscList
	let eTag: String?
}
