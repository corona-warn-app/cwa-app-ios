//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class MockURLSessionDataTask: URLSessionDataTask, URLAuthenticationChallengeSender {
	func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {

	}

	func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {

	}

	func cancel(_ challenge: URLAuthenticationChallenge) {

	}

	private let completion: () -> Void
	private let session: URLSession
	private weak var sessionDelegate: URLSessionDelegate?

	init(
		completion: @escaping () -> Void,
		session: URLSession,
		sessionDelegate: URLSessionDelegate?
	) {
		self.completion = completion
		self.session = session
		self.sessionDelegate = sessionDelegate
	}

	override func resume() {

		if let delegate = sessionDelegate as? CoronaWarnSessionTaskDelegate {
			let challenge = URLAuthenticationChallenge(protectionSpace: URLProtectionSpace(host: "", port: 0, protocol: nil, realm: nil, authenticationMethod: nil), proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: self)

			delegate.urlSession(
				session,
				task: self,
				didReceive: challenge,
				completionHandler: { [weak self] _, _ in
					self?.completion()
				}
			)
		} else {
			completion()
		}
	}
}

class MockUrlSession: URLSession {
	typealias URLRequestObserver = ((URLRequest) -> Void)

	var data: Data?
	var nextResponse: URLResponse?
	var error: Error?

	var onPrepareResponse: (() -> Void)?
	var onURLRequestObserver: URLRequestObserver?
	// swiftlint:disable weak_delegate
	var sessionDelegate: URLSessionDelegate?

	override var delegate: URLSessionDelegate? {
		sessionDelegate
	}

	init(
		data: Data?,
		nextResponse: URLResponse?,
		error: Error?,
		urlRequestObserver: URLRequestObserver? = nil,
		sessionDelegate: URLSessionDelegate? = nil
	) {
		self.data = data
		self.nextResponse = nextResponse
		self.error = error
		self.onURLRequestObserver = urlRequestObserver
		self.sessionDelegate = sessionDelegate
	}

	func prepareForDataTask(data: Data?, response: URLResponse?) {
		self.data = data
		self.nextResponse = response
	}

	override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		onURLRequestObserver?(URLRequest(url: url))
		onPrepareResponse?()
		return MockURLSessionDataTask(
			completion: {
				completionHandler(self.data, self.nextResponse, self.error)
			},
			session: self,
			sessionDelegate: self.delegate
		)
	}

	override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		onURLRequestObserver?(request)
		onPrepareResponse?()
		return MockURLSessionDataTask(
			completion: {
				completionHandler(self.data, self.nextResponse, self.error)
			},
			session: self,
			sessionDelegate: self.delegate
		)
	}
}
