//
// 🦠 Corona-Warn-App
//

struct DigitalCovid19CertificateReceiveModel: Codable {

	// data encryption key, base64 encoded
	let dek: String
	// COSE-Object, base64 encoded
	let dcc: String

}

struct DCC500Response: Codable {
	let reason: String
}
