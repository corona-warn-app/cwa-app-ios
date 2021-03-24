//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

/// A provider of the QR Code Poster Template
protocol QRCodePosterTemplateProviding: AnyObject {

	/// Provides the latest QR Code Poster Template
	func latestQRCodePosterTemplate() -> AnyPublisher<SAP_Internal_Pt_QRCodePosterTemplateIOS, Error>
}

/// Some requirements for QR Code Poster Template handling
protocol QRCodePosterTemplateFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var packageVerifier: SAPDownloadedPackage.Verifier { get }

	typealias QRCodePosterTemplateCompletionHandler = (Result<QRCodePosterTemplateResponse, Error>) -> Void

	// MARK: QRCodePosterTemplateFetching
	
	/// Fetches the QR Code Poster Template Protobuf
	/// - Parameters:
	/// - etag: an optional ETag to download only versions that differ the given tag
	/// - completion: The completion handler of the get call, which contains the prootbuf response
	func fetchQRCodePosterTemplateData(
		etag: String?,
		completion: @escaping QRCodePosterTemplateCompletionHandler
	)
}

/// Helper struct to collect some required data.
struct QRCodePosterTemplateResponse {
	let qrCodePosterTemplate: SAP_Internal_Pt_QRCodePosterTemplateIOS
	let eTag: String?
	let timestamp: Date

	init(_ config: SAP_Internal_Pt_QRCodePosterTemplateIOS, _ eTag: String? = nil) {
		self.qrCodePosterTemplate = config
		self.eTag = eTag
		self.timestamp = Date()
	}
}
