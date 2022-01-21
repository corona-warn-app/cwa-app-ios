//
// 🦠 Corona-Warn-App
//

/**
 Generel model to encapsulate the real model, which has to fullfill CBORDecoding. The main purpose of this model is to store a property if the real model returned from the service is from the cache or freshly fetched. Normally you cannot differentiate here.
 */
struct ModelWithCache<M>: CBORDecoding where M: CBORDecoding {
	
	typealias Model = M
	
	let model: M
	let isCached: Bool
	
	static func decode(_ data: Data) -> Result<M, ModelDecodingError> {
//		return M.decode(data)
		return .failure(.CBOR_DECODING)
	}
}
