//
// 🦠 Corona-Warn-App
//

import Foundation

enum DigitalCovid19CertificateError: Error, Equatable {
    case urlCreationFailed
    case unhandledResponse(Int)
    case jsonError
    case dccPending
    case badRequest
    case tokenDoesNotExist
    case dccAlreadyCleanedUp
    case testResultNotYetReceived
    case internalServerError(reason: String?)
    case defaultServerError(Error)
    case noNetworkConnection

    // MARK: - Protocol Equatable

    static func == (lhs: DigitalCovid19CertificateError, rhs: DigitalCovid19CertificateError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}
