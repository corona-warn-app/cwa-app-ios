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
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding,
		qrCodeErrorCorrectionLevel: String
	) {
		self.traceLocation = traceLocation
		self.store = store
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider
		self.qrCodeErrorCorrectionLevel = qrCodeErrorCorrectionLevel
	}

	enum TableViewSections: Int, CaseIterable {
		case header
		case location
		case qrCode
		case dateTime
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

	var date: String? {
		if let startDate = traceLocation.startDate, let endDate = traceLocation.endDate {
			let dateFormatter = DateIntervalFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.timeStyle = .short

			return dateFormatter.string(from: startDate, to: endDate)
		} else {
			return nil
		}
	}
	
	var qrCode: UIImage? {
		guard let qrCodeImage = traceLocation.qrCode(size: CGSize(width: 300, height: 300)) else { return nil }
		return qrCodeImage
	}

	var numberOfRowsPerSection: Int {
		// since every section has only one row
		return 1
	}

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
	private let qrCodeErrorCorrectionLevel: String
	private var subscriptions = Set<AnyCancellable>()
	@OpenCombine.Published private(set) var qrCodePosterTemplate: SAP_Internal_Pt_QRCodePosterTemplateIOS = SAP_Internal_Pt_QRCodePosterTemplateIOS()
}
