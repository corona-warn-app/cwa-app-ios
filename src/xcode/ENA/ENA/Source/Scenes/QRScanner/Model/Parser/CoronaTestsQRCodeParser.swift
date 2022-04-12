//
// 🦠 Corona-Warn-App
//

import Foundation

class CoronaTestsQRCodeParser: QRCodeParsable {
	
	// MARK: - Init

	init() {
	}

	// MARK: - Protocol QRCodeParsable
	
	func parse(
		qrCode: String,
		completion: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void
	) {
		Log.info("Parse corona test.")

		#if DEBUG
		if isUITesting {
			completion(.success(.coronaTest(CoronaTestRegistrationInformation.pcr(guid: "guid", qrCodeHash: "qrCodeHash"))))
		}
		#endif

		let result = coronaTestQRCodeInformation(from: qrCode)
		switch result {

		case let .success(coronaTestQRCodeInformation):
			completion(.success(.coronaTest(coronaTestQRCodeInformation)))
		case let .failure(qrCodeParserError):
			Log.info("Failed parsing corona test with error codeNotFound")
			completion(.failure(qrCodeParserError))
		}
	}

	// MARK: - Internal

	/// Filters the input string and extracts a guid.
	/// - the input needs to start with https://localhost/?
	/// - the input must not be longer than 150 chars and cannot be empty
	/// - the guid contains only the following characters: a-f, A-F, 0-9,-
	/// - the guid is a well formatted string (6-8-4-4-4-12) with length 43
	///   (6 chars encode a random number, 32 chars for the uuid, 5 chars are separators)
	func coronaTestQRCodeInformation(
        from input: String
    ) -> Result<CoronaTestRegistrationInformation, QRCodeParserError> {
        // general checks for both PCR and Rapid tests
        guard !input.isEmpty,
              let urlComponents = URLComponents(string: input),
              !urlComponents.path.contains(" "),
              urlComponents.scheme?.lowercased() == "https" else {
                  return .failure(.scanningError(.codeNotFound))
              }
        // specific checks based on test type
        if urlComponents.host?.lowercased() == "localhost" {
            return pcrTestInformation(from: input, urlComponents: urlComponents)
        } else if let route = Route(input),
                  case .rapidAntigen(let testInformationResult) = route {
            if case let .success(testInformation) = testInformationResult {
                return .success(testInformation)
            }
            if case let .failure(qrCodeError) = testInformationResult {
                return .failure(.invalidError(qrCodeError))
            }
        } else if let route = Route(input),
                  case .rapidPCR(let testInformationResult) = route {
            if case let .success(testInformation) = testInformationResult {
                return .success(testInformation)
            }
            if case let .failure(qrCodeError) = testInformationResult {
                return .failure(.invalidError(qrCodeError))
            }
        }
        return .failure(.scanningError(.codeNotFound))
    }

	// MARK: - Private
	
	private func pcrTestInformation(
		from guidURL: String,
		urlComponents: URLComponents
	) -> Result<CoronaTestRegistrationInformation, QRCodeParserError> {
		guard guidURL.count <= 150,
			  urlComponents.path.components(separatedBy: "/").count == 2,	// one / will separate into two components
			  let candidate = urlComponents.query,
			  candidate.count == 43,
			  let matchings = candidate.range(
				of: #"^[0-9A-Fa-f]{6}-[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$"#,
				options: .regularExpression
			  ),
			  !matchings.isEmpty
		else {
			return .failure(.scanningError(.codeNotFound))
		}

		return .success(.pcr(guid: candidate, qrCodeHash: ENAHasher.sha256(guidURL)))
	}
	
}
