//
// 🦠 Corona-Warn-App
//

import Foundation

struct QRCodePosterTemplateMetadata: Codable, Equatable {
	
	// MARK: - Init
	
	init(with response: QRCodePosterTemplateResponse) {
		self.lastQRCodePosterTemplateETag = response.eTag
		self.lastQRCodePosterTemplateFetchDate = response.timestamp
		self.qrCodePosterTemplate = response.qrCodePosterTemplate
	}

	init(
		lastQRCodePosterTemplateETag: String,
		lastQRCodePosterTemplateFetchDate: Date,
		qrCodePosterTemplate: SAP_Internal_Pt_QRCodePosterTemplateIOS
	) {
		self.lastQRCodePosterTemplateETag = lastQRCodePosterTemplateETag
		self.lastQRCodePosterTemplateFetchDate = lastQRCodePosterTemplateFetchDate
		self.qrCodePosterTemplate = qrCodePosterTemplate
	}
	
	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case lastQRCodePosterTemplateETag
		case lastQRCodePosterTemplateFetchDate
		case qrCodePosterTemplate
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		lastQRCodePosterTemplateETag = try container.decode(String.self, forKey: .lastQRCodePosterTemplateETag)
		lastQRCodePosterTemplateFetchDate = try container.decode(Date.self, forKey: .lastQRCodePosterTemplateFetchDate)

		let qrCodePosterTemplateData = try container.decode(Data.self, forKey: .qrCodePosterTemplate)
		qrCodePosterTemplate = try SAP_Internal_Pt_QRCodePosterTemplateIOS(serializedData: qrCodePosterTemplateData)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(lastQRCodePosterTemplateETag, forKey: .lastQRCodePosterTemplateETag)
		try container.encode(lastQRCodePosterTemplateFetchDate, forKey: .lastQRCodePosterTemplateFetchDate)

		let qrCodePosterTemplateData = try qrCodePosterTemplate.serializedData()
		try container.encode(qrCodePosterTemplateData, forKey: .qrCodePosterTemplate)
	}
	
	// MARK: - Internal
	
	var lastQRCodePosterTemplateETag: String?
	var lastQRCodePosterTemplateFetchDate: Date
	var qrCodePosterTemplate: SAP_Internal_Pt_QRCodePosterTemplateIOS
	
	mutating func refeshLastQRCodePosterTemplateFetchDate() {
		lastQRCodePosterTemplateFetchDate = Date()
	}
}
