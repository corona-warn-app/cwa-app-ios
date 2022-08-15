//
// 🦠 Corona-Warn-App
//

import Foundation

enum SubmitELSResourceError: Error {
	
	case ppacError(PPACError)
	case otpError(OTPError)
	case urlCreationError
	case responseError(Int)
	case jsonError
	case defaultServerError(Error)
	case emptyLogFile
	case couldNotReadLogfile(_ message: String? = nil)
}

struct SubmitELSResource: Resource {
	init(
		errorLogFile: Data,
		otpEls: String,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		// prevent potential file collisions on backend
		let fileName = "ErrorLog-\(UUID().uuidString).zip"
		let boundary = UUID().uuidString

		var body = Data()
		do {
			try body.append("\r\n--\(boundary)\r\n")
			try body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
			try body.append("Content-Type:application/zip\r\n")
			try body.append("Content-Length: \(errorLogFile.count)\r\n")
			try body.append("\r\n")
			body.append(errorLogFile)
			try body.append("\r\n")
			try body.append("--\(boundary)--\r\n")
		} catch {
			Log.error(error.localizedDescription, log: .els)
		}
		self.locator = .submitELS(payload: body, otpEls: otpEls, boundary: boundary)
		self.sendResource = JSONSendResource<SubmitElSSendModel>(SubmitElSSendModel(body: body))
		self.type = .default
		self.receiveResource = JSONReceiveResource<SubmitELSReceiveModel>()
		self.trustEvaluation = trustEvaluation
	}
	
	// MARK: - Protocol Resource
	typealias Send = JSONSendResource<SubmitElSSendModel>
	typealias Receive = JSONReceiveResource<SubmitELSReceiveModel>
	typealias CustomError = ELSError

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<SubmitElSSendModel>
	var receiveResource: JSONReceiveResource<SubmitELSReceiveModel>
}