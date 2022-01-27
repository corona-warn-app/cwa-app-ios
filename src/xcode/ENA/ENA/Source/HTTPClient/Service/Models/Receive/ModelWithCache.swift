//
// 🦠 Corona-Warn-App
//

/**
 Generel model to encapsulate the real model, which has to fullfill CBORDecoding. The main purpose of this model is to store a property if the real model returned from the service is from the cache or freshly fetched. Normally you cannot differentiate here.
 */
struct ModelWithCache<WrappedModel>: CBORDecodable, MetaDataProviding where WrappedModel: CBORDecodable {

		
	// MARK: - CBORDecoding
	
	static func make(with data: Data) -> Result<ModelWithCache, ModelDecodingError> {
		let result = WrappedModel.make(with: data)
		switch result {
			
		case let .success(someModel):
			// We need that cast for the compiler.
			if let wrappedModel = someModel as? WrappedModel {
				return .success(
					ModelWithCache(
						model: wrappedModel,
						loadedFromCache: false
					)
				)
			} else {
				return .failure(.CBOR_DECODING)
			}

		case let .failure(error):
			return .failure(error)
		}
	}
	
	// MARK: - ModelWithCaching

	var metaData: MetaData = MetaData()

	var loadedFromCache: Bool

	// MARK: - Internal
	
	let model: WrappedModel
	
	// MARK: - Private
	
	private init(
		model: WrappedModel,
		loadedFromCache: Bool
	) {
		self.model = model
		self.loadedFromCache = loadedFromCache
	}
}
