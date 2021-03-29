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
			let endsOnSameDay = Calendar.current.isDate(startDate, inSameDayAs: endDate)

			let dateFormatter = DateIntervalFormatter()
			dateFormatter.dateStyle = traceLocation.isActive && endsOnSameDay ? .none : .short
			dateFormatter.timeStyle = .short

			return dateFormatter.string(from: startDate, to: endDate)
		} else {
			return nil
		}
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
	private var subscriptions = Set<AnyCancellable>()
	@OpenCombine.Published private(set) var qrCodePosterTemplate: SAP_Internal_Pt_QRCodePosterTemplateIOS = SAP_Internal_Pt_QRCodePosterTemplateIOS()
}
