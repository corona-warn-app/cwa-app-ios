//
// 🦠 Corona-Warn-App
//

import Foundation

public protocol HTTPServiceProtocol {
    func execute(
        request: URLRequest,
        urlSession: URLSession,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    )
}

public struct HTTPService: HTTPServiceProtocol {

    public init() {}

    public func execute(
        request: URLRequest,
        urlSession: URLSession,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

        let task = urlSession.dataTask(with: request, completionHandler: completion)
        task.resume()
    }
}
