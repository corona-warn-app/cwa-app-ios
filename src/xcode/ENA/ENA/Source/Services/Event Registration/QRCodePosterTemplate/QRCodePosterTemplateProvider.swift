//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class QRCodePosterTemplateProvider: QRCodePosterTemplateProviding {

	// MARK: - Init

	/// Default initializer
	/// - Parameters:
	///   - client: The client to fetch the QR Code Poster Template
	///   - store: Used for caching
	init(client: QRCodePosterTemplateFetching, store: Store) {
		self.client = client
		self.store = store
	}

	// MARK: - Internal

	func latestQRCodePosterTemplate() -> AnyPublisher<SAP_Internal_Pt_QRCodePosterTemplateIOS, Error> {
		guard let cached = store.qrCodePosterTemplateMetadata, !shouldFetch() else {
			return fetchQRCodePosterTemplate().eraseToAnyPublisher()
		}
		// return cached data; no error
		return Just(cached.qrCodePosterTemplate)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	func defaultQRCodePosterTemplate() -> SAP_Internal_Pt_QRCodePosterTemplateIOS {
		guard
			let url = Bundle(for: type(of: self)).url(forResource: "qr_code_template", withExtension: "bin"),
			let data = try? Data(contentsOf: url),
			let template = try? SAP_Internal_Pt_QRCodePosterTemplateIOS(serializedData: data)
		else {
			fatalError("Cannot load default QR code poster template")
		}
		return template
	}

	// MARK: - Private

	/// HTTP client
	private let client: QRCodePosterTemplateFetching

	/// The place where the QR Code Poster Template and last etag is stored
	private let store: QRCodePosterTemplateCaching

	private func fetchQRCodePosterTemplate(with etag: String? = nil) -> Future<SAP_Internal_Pt_QRCodePosterTemplateIOS, Error> {
		return Future { promise in
			self.client.fetchQRCodePosterTemplateData(etag: etag) { result in
				switch result {
				case .success(let response):
					// cache
					self.store.qrCodePosterTemplateMetadata = QRCodePosterTemplateMetadata(with: response)
					promise(.success(response.qrCodePosterTemplate))
				case .failure(let error):
					switch error {
					case URLSessionError.notModified:
						self.store.qrCodePosterTemplateMetadata?.refeshLastQRCodePosterTemplateFetchDate()
					default:
						break
					}
					// always return cached QR Code Poster Template if available from current day
					if let template = self.store.qrCodePosterTemplateMetadata, Calendar.current.isDateInToday(template.lastQRCodePosterTemplateFetchDate) {
						promise(.success(template.qrCodePosterTemplate))
					} else {
						// otherwise return default QR Code Poster Template
						promise(.success(self.defaultQRCodePosterTemplate()))
					}
				}
			}
		}
	}

	/// Simple helper to simulate Cache-Control
	/// - Note: This 300 second value is because of current handicaps with the HTTPClient architecture
	///   which does not easily return response headers. This requires further refactoring of `URLSession+Convenience.swift`.
	/// - Returns: `true` is a network call should be done; `false` if cache should be used
	private func shouldFetch() -> Bool {
		if store.qrCodePosterTemplateMetadata == nil { return true }

		// naïve cache control
		guard let lastFetch = store.qrCodePosterTemplateMetadata?.lastQRCodePosterTemplateFetchDate else {
			return true
		}
		Log.debug("timestamp >= 300s? \(abs(Date().timeIntervalSince(lastFetch))) >= 300)", log: .qrCode)
		return abs(Date().timeIntervalSince(lastFetch)) >= 300
	}
}
