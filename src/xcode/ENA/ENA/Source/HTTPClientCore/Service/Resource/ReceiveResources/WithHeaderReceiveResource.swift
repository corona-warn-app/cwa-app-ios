//
// 🦠 Corona-Warn-App
//

import Foundation

struct WithHeaderReceiveResource<R: ReceiveResource>: ReceiveResource {

	// MARK: - Init

	init(receiveResource: R) {
		self.receiveResource = receiveResource
	}
	
	// MARK: - Protocol ReceiveResource

	typealias ReceiveModel = ModelWithHeaders<R.ReceiveModel>

	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<ModelWithHeaders<R.ReceiveModel>, ResourceError> {
		switch receiveResource.decode(data, headers: headers) {
		case .success(let receiveModel):
			return .success(ModelWithHeaders(model: receiveModel, headers: headers))
		case .failure(let error):
			return .failure(error)
		}
	}

	private let receiveResource: R

}
