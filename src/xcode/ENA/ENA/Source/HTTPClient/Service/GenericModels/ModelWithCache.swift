//
// 🦠 Corona-Warn-App
//

protocol ModelWithCaching {
	var isCached: Bool { get set }
}

/**
 Generel model to encapsulate the real model, which has to fullfill CBORDecoding. The main purpose of this model is to store a property if the real model returned from the service is from the cache or freshly fetched. Normally you cannot differentiate here.
 */
struct ModelWithCache<WrappedModel>: CBORDecoding, ModelWithCaching where WrappedModel: CBORDecoding {
		
	// MARK: - CBORDecoding
	
	static func decode(_ data: Data) -> Result<ModelWithCache, ModelDecodingError> {
		let result = WrappedModel.decode(data)
		switch result {
			
		case let .success(someModel):
			// We need that cast for the compiler.
			if let wrappedModel = someModel as? WrappedModel {
				return .success(ModelWithCache(model: wrappedModel, isCached: false))
			} else {
				return .failure(.CBOR_DECODING)
			}

		case let .failure(error):
			return .failure(error)
		}
	}
	
	// MARK: - ModelWithCaching

	var isCached: Bool

	// MARK: - Internal
	
	let model: WrappedModel
	
	// MARK: - Private
	
	private init(
		model: WrappedModel,
		isCached: Bool
	) {
		self.model = model
		self.isCached = isCached
	}
}
