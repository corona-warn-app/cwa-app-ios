////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TicketValidationQRCodeParserTests: CWATestCase {

    func testValidJSON() {
		let validPayload = """
		{
			"protocol": "DCCVALIDATION",
			"protocolVersion": "1.0.0",
			"serviceIdentity": "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity",
			"privacyUrl": "https://validation-decorator.example",
			"token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJiUzhEMi9XejV0WT0iLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RnY2EtYm9va2luZy1kZW1vLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20vYXBpL2lkZW50aXR5IiwiZXhwIjoxNjM1NDk2MzYwLCJzdWIiOiIwMDI0MWQxMS0yN2I0LTQxYWYtOWU3Ny0zNDE4YzNlY2NmZDQifQ.X0wUdET3omy3qXyOhBh1UuAUEvfYMCdapv0yVShynfZpc4yS3kH57TrPLgSqS7A9ZhbgIdCIfZwr0Chm1ELyTw",
			"consent": "Please confirm to start the DCC exchange flow. If you not confirm, the flow is aborted.",
			"subject": "00241d11-27b4-41af-9e77-3418c3eccfd4",
			"serviceProvider": "Booking Demo"
		}
		"""

		let completionExpectation = expectation(description: "completion called")

		let qrCodeParser = TicketValidationQRCodeParser()
		qrCodeParser.parse(
			qrCode: validPayload,
			completion: { result in
				switch result {
				case .success:
					break
				case .failure:
					XCTFail("Expected success")
				}

				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
	}

	func testValidJSONWithLowercaseProtocol() {
		let validPayload = """
		{
			"protocol": "dccvalidation",
			"protocolVersion": "1.0.0",
			"serviceIdentity": "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity",
			"privacyUrl": "https://validation-decorator.example",
			"token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJiUzhEMi9XejV0WT0iLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RnY2EtYm9va2luZy1kZW1vLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20vYXBpL2lkZW50aXR5IiwiZXhwIjoxNjM1NDk2MzYwLCJzdWIiOiIwMDI0MWQxMS0yN2I0LTQxYWYtOWU3Ny0zNDE4YzNlY2NmZDQifQ.X0wUdET3omy3qXyOhBh1UuAUEvfYMCdapv0yVShynfZpc4yS3kH57TrPLgSqS7A9ZhbgIdCIfZwr0Chm1ELyTw",
			"consent": "Please confirm to start the DCC exchange flow. If you not confirm, the flow is aborted.",
			"subject": "00241d11-27b4-41af-9e77-3418c3eccfd4",
			"serviceProvider": "Booking Demo"
		}
		"""

		let completionExpectation = expectation(description: "completion called")

		let qrCodeParser = TicketValidationQRCodeParser()
		qrCodeParser.parse(
			qrCode: validPayload,
			completion: { result in
				switch result {
				case .success:
					break
				case .failure:
					XCTFail("Expected success")
				}

				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
	}

	func testParseErrorFromInvalidJSON() {
		let validPayload = """
		{
			"someOtherProperty": "someOtherValue"
		}
		"""

		let completionExpectation = expectation(description: "completion called")

		let qrCodeParser = TicketValidationQRCodeParser()
		qrCodeParser.parse(
			qrCode: validPayload,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Expected success")
				case .failure(let error):
					XCTAssertEqual(error, .ticketValidation(.INIT_DATA_PARSE_ERR))
				}

				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
	}

	func testInvalidProtocol() {
		let validPayload = """
		{
			"protocol": "someOtherProtocol",
			"protocolVersion": "1.0.0",
			"serviceIdentity": "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity",
			"privacyUrl": "https://validation-decorator.example",
			"token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJiUzhEMi9XejV0WT0iLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RnY2EtYm9va2luZy1kZW1vLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20vYXBpL2lkZW50aXR5IiwiZXhwIjoxNjM1NDk2MzYwLCJzdWIiOiIwMDI0MWQxMS0yN2I0LTQxYWYtOWU3Ny0zNDE4YzNlY2NmZDQifQ.X0wUdET3omy3qXyOhBh1UuAUEvfYMCdapv0yVShynfZpc4yS3kH57TrPLgSqS7A9ZhbgIdCIfZwr0Chm1ELyTw",
			"consent": "Please confirm to start the DCC exchange flow. If you not confirm, the flow is aborted.",
			"subject": "00241d11-27b4-41af-9e77-3418c3eccfd4",
			"serviceProvider": "Booking Demo"
		}
		"""

		let completionExpectation = expectation(description: "completion called")

		let qrCodeParser = TicketValidationQRCodeParser()
		qrCodeParser.parse(
			qrCode: validPayload,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Expected success")
				case .failure(let error):
					XCTAssertEqual(error, .ticketValidation(.INIT_DATA_PROTOCOL_INVALID))
				}

				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
	}

	func testEmptySubject() {
		let validPayload = """
		{
			"protocol": "DCCVALIDATION",
			"protocolVersion": "1.0.0",
			"serviceIdentity": "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity",
			"privacyUrl": "https://validation-decorator.example",
			"token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJiUzhEMi9XejV0WT0iLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RnY2EtYm9va2luZy1kZW1vLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20vYXBpL2lkZW50aXR5IiwiZXhwIjoxNjM1NDk2MzYwLCJzdWIiOiIwMDI0MWQxMS0yN2I0LTQxYWYtOWU3Ny0zNDE4YzNlY2NmZDQifQ.X0wUdET3omy3qXyOhBh1UuAUEvfYMCdapv0yVShynfZpc4yS3kH57TrPLgSqS7A9ZhbgIdCIfZwr0Chm1ELyTw",
			"consent": "Please confirm to start the DCC exchange flow. If you not confirm, the flow is aborted.",
			"subject": "",
			"serviceProvider": "Booking Demo"
		}
		"""

		let completionExpectation = expectation(description: "completion called")

		let qrCodeParser = TicketValidationQRCodeParser()
		qrCodeParser.parse(
			qrCode: validPayload,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Expected success")
				case .failure(let error):
					XCTAssertEqual(error, .ticketValidation(.INIT_DATA_SUBJECT_EMPTY))
				}

				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
	}

	func testEmptyServiceProvider() {
		let validPayload = """
		{
			"protocol": "DCCVALIDATION",
			"protocolVersion": "1.0.0",
			"serviceIdentity": "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity",
			"privacyUrl": "https://validation-decorator.example",
			"token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJiUzhEMi9XejV0WT0iLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RnY2EtYm9va2luZy1kZW1vLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20vYXBpL2lkZW50aXR5IiwiZXhwIjoxNjM1NDk2MzYwLCJzdWIiOiIwMDI0MWQxMS0yN2I0LTQxYWYtOWU3Ny0zNDE4YzNlY2NmZDQifQ.X0wUdET3omy3qXyOhBh1UuAUEvfYMCdapv0yVShynfZpc4yS3kH57TrPLgSqS7A9ZhbgIdCIfZwr0Chm1ELyTw",
			"consent": "Please confirm to start the DCC exchange flow. If you not confirm, the flow is aborted.",
			"subject": "00241d11-27b4-41af-9e77-3418c3eccfd4",
			"serviceProvider": ""
		}
		"""

		let completionExpectation = expectation(description: "completion called")

		let qrCodeParser = TicketValidationQRCodeParser()
		qrCodeParser.parse(
			qrCode: validPayload,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Expected success")
				case .failure(let error):
					XCTAssertEqual(error, .ticketValidation(.INIT_DATA_SP_EMPTY))
				}

				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
	}
	
}
