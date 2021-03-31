////
// 🦠 Corona-Warn-App
//

import Foundation

extension SAP_Internal_Pt_QRCodePayload {
	var id: Data? {
		guard var data = "CWA-GUID".data(using: .utf8), let qrCodePayloadData = try? serializedData() else {
			return nil
		}
		data.append(qrCodePayloadData)
		return data.sha256()
	}
}
