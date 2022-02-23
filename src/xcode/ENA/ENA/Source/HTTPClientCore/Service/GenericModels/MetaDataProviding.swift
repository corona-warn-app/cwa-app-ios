//
// 🦠 Corona-Warn-App
//

import Foundation

/**
 Extend a model used by some resource by this protocol to add some metaData to your model.
 */
protocol MetaDataProviding {
	var metaData: MetaData { get set }
}

/**
 Adds some more informations to a model used by some resource.
 - loadedFromCache: return true if the model is loaded from the cache. Otherwise it is fetched from the server and return false
 - headers: Contains all headers from the httpResponse. Intention is to look up into the headers for some special header fields.
 
 */
struct MetaData {
	var loadedFromDefault: Bool = false
	var loadedFromCache: Bool = false
	var headers: [AnyHashable: Any] = [:]
}
