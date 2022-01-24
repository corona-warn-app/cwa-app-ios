//
// 🦠 Corona-Warn-App
//

/**
 Generel model to encapsulate the real model, which has to fullfill CBORDecoding. The main purpose of this model is to store a property if the real model returned from the service is from the cache or freshly fetched. Normally you cannot differentiate here.
 */
struct ModelWithCache<M>: CBORDecoding where M: CBORDecoding {
		
	static func decode(_ data: Data) -> Result<ModelWithCache, ModelDecodingError> {
		let result = M.decode(data)
		switch result {
			
		case let .success(someModel):
			// We need that cast for the compiler.
			if let wrappedModel = someModel as? M {
				return Result.success(ModelWithCache(model: wrappedModel, isCached: false))
			} else {
				return .failure(.CBOR_DECODING)
			}

		case let .failure(error):
			return .failure(error)
		}
	}
	
	// MARK: - Internal
	
	let model: M
	var isCached: Bool
	
	// MARK: - Private
	
	private init(
		model: M,
		isCached: Bool
	) {
		self.model = model
		self.isCached = isCached
	}
}
