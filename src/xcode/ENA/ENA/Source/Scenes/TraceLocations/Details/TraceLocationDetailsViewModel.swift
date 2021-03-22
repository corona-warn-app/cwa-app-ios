//
// 🦠 Corona-Warn-App
//

import Foundation
import PDFKit
import OpenCombine

class TraceLocationDetailsViewModel {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		store: Store,
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding
	) {
		self.traceLocation = traceLocation
		self.store = store
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider
	}

	// MARK: - Internal

	let traceLocation: TraceLocation
	typealias QRCodePosterTemplateCompletionHandler = (Result<SAP_Internal_Pt_QRCodePosterTemplateIOS, Error>) -> Void

	func fetchQRCodePosterTemplateData(completion: @escaping QRCodePosterTemplateCompletionHandler) {
		qrCodePosterTemplateProvider.latestQRCodePosterTemplate()
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

	private let store: Store
	private let qrCodePosterTemplateProvider: QRCodePosterTemplateProviding
	private var subscriptions = Set<AnyCancellable>()
	@OpenCombine.Published private(set) var qrCodePosterTemplate: SAP_Internal_Pt_QRCodePosterTemplateIOS = SAP_Internal_Pt_QRCodePosterTemplateIOS()
}
