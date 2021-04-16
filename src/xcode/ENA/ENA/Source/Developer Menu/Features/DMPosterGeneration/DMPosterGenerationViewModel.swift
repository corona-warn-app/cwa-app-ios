////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import OpenCombine

final class DMPosterGenerationViewModel {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding,
		store: Store
	) {
		self.traceLocation = traceLocation
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider
		self.store = store
	}

	// MARK: - Internal

	let traceLocation: TraceLocation
	typealias QRCodePosterTemplateCompletionHandler = (Result<SAP_Internal_Pt_QRCodePosterTemplateIOS, Error>) -> Void

	var title: String {
		return traceLocation.description
	}
	
	var address: String {
		return traceLocation.address
	}

	func fetchQRCodePosterTemplateData(completion: @escaping QRCodePosterTemplateCompletionHandler) {
		qrCodePosterTemplateProvider.latestQRCodePosterTemplate(with: store.qrCodePosterTemplateMetadata?.lastQRCodePosterTemplateETag)
			.sink(
				receiveCompletion: { result in
					switch result {
					case .finished:
						break
					case .failure(let error):
						if case CachingHTTPClient.CacheError.dataVerificationError = error {
							Log.error("Signature verification error.", log: .qrCode, error: error)
							completion(.failure(error))
						}
						Log.error("Could not fetch QR code poster template protobuf.", log: .qrCode, error: error)
						completion(.failure(error))
					}
				}, receiveValue: { [weak self] in
					self?.qrCodePosterTemplate = $0
					completion(.success($0))
				}
			)
			.store(in: &subscriptions)
	}

	// MARK: - Private

	private let qrCodePosterTemplateProvider: QRCodePosterTemplateProviding
	private let store: Store
	private var subscriptions = Set<AnyCancellable>()
	@OpenCombine.Published private(set) var qrCodePosterTemplate: SAP_Internal_Pt_QRCodePosterTemplateIOS = SAP_Internal_Pt_QRCodePosterTemplateIOS()
}
#endif
