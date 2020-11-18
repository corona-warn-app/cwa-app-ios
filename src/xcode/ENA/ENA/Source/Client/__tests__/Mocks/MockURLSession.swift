//
// 🦠 Corona-Warn-App
//

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
	private let completion: () -> Void

	init(completion: @escaping () -> Void) {
		self.completion = completion
	}

	override func resume() {
		completion()
	}
}

class MockUrlSession: URLSession {
	typealias URLRequestObserver = ((URLRequest) -> Void)

	var data: Data?
	var nextResponse: URLResponse?
	var error: Error?

	var onPrepareResponse: (() -> Void)?
	var onURLRequestObserver: URLRequestObserver?

	init(
		data: Data?,
		nextResponse: URLResponse?,
		error: Error?,
		urlRequestObserver: URLRequestObserver? = nil
	) {
		self.data = data
		self.nextResponse = nextResponse
		self.error = error
		self.onURLRequestObserver = urlRequestObserver
	}

	func prepareForDataTask(data: Data?, response: URLResponse?) {
		self.data = data
		self.nextResponse = response
	}

	override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		onURLRequestObserver?(URLRequest(url: url))
		onPrepareResponse?()
		return MockURLSessionDataTask {
			completionHandler(self.data, self.nextResponse, self.error)
		}
	}

	override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		onURLRequestObserver?(request)
		onPrepareResponse?()
		return MockURLSessionDataTask {
			completionHandler(self.data, self.nextResponse, self.error)
		}
	}
}
