//
//  HTTPClient.swift
//  ENA
//
//  Created by Bormeth, Marc on 10.05.20.
//

import Foundation
import ExposureNotification

class HTTPClient: Client {

    init(config: BackendConfig, session: URLSession = URLSession.shared) {
        self.config = config
        self.session = session
    }

    // MARK: Properties
    private let config: BackendConfig
    private let session: URLSession
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy-mm-dd"
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
        
    }

    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {

    }

    func fetch(completion: @escaping FetchKeysCompletionHandler) {

    }
}

extension URLSession {
    func dataTask(
        with url: URL,
        handler: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: url) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(data ?? Data()))
            }
        }
    }
}
