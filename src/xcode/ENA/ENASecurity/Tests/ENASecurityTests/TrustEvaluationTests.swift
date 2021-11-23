//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENASecurity
import ASN1Decoder

class TrustEvaluationTests: XCTestCase {

    func test_FingerprintAndKeyIdentifier() throws {
        let derBase64 = try XCTUnwrap(Data(base64Encoded: derBase64Key))
        let fingerprint = "E8:7E:26:EB:9D:22:28:01:25:E1:13:F7:55:BE:2F:9F:90:DB:07:6D:D0:11:D5:94:0E:0A:78:DD:2F:20:ED:FA".replacingOccurrences(of: ":", with: "").dataWithHexString()
        let keyIdentifier = try XCTUnwrap(Data(base64Encoded: keyIdentifier))

        XCTAssertEqual(derBase64.fingerprint, fingerprint.base64EncodedString())
        XCTAssertEqual(derBase64.keyIdentifier, keyIdentifier.base64EncodedString())
    }

    func test_CheckServerKeyAgainstJWKSetSucccess() throws {
        let jsonEncoder = JSONEncoder()
        let jwkSet = [
            try jsonEncoder.encode(JSONWebKey(x5c: [derBase64Key], kid: keyIdentifier, alg: "", use: "")),
            try jsonEncoder.encode(JSONWebKey(x5c: [""], kid: "", alg: "", use: "")),
            try jsonEncoder.encode(JSONWebKey(x5c: [""], kid: "", alg: "", use: ""))
        ]
        let derBase64 = try XCTUnwrap(Data(base64Encoded: derBase64Key))
        let trustEvaluation = TrustEvaluation()

        let result = trustEvaluation.check(serverKeyData: derBase64, against: jwkSet)

        if case .failure(let error) = result {
            XCTFail("Failed with error: \(error)")
            return
        }
    }

    func test_CheckServerKeyAgainstJWKSetError_CERT_PIN_NO_JWK_FOR_KID() throws {
        let jsonEncoder = JSONEncoder()
        let jwkSet = [
            try jsonEncoder.encode(JSONWebKey(x5c: [derBase64Key], kid: "", alg: "", use: "")),
            try jsonEncoder.encode(JSONWebKey(x5c: [""], kid: "", alg: "", use: "")),
            try jsonEncoder.encode(JSONWebKey(x5c: [""], kid: "", alg: "", use: ""))
        ]
        let derBase64 = try XCTUnwrap(Data(base64Encoded: derBase64Key))
        let trustEvaluation = TrustEvaluation()

        let result = trustEvaluation.check(serverKeyData: derBase64, against: jwkSet)

        guard case .failure(let error) = result,
              error == .CERT_PIN_NO_JWK_FOR_KID else {

            XCTFail("CERT_PIN_NO_JWK_FOR_KID error expected.")
            return
        }
    }

    func test_CheckServerKeyAgainstJWKSetError_CERT_PIN_MISMATCH() throws {
        // To test this error scenario we need to pass only the first correct part of the certificate.
        // This way the KID check will be successful, but the fingerprint check will fail.

        let jsonEncoder = JSONEncoder()
        let jwkSet = [
            try jsonEncoder.encode(JSONWebKey(x5c: ["MIIKYjCCCUq"], kid: keyIdentifier, alg: "", use: "")),
            try jsonEncoder.encode(JSONWebKey(x5c: [""], kid: "", alg: "", use: "")),
            try jsonEncoder.encode(JSONWebKey(x5c: [""], kid: "", alg: "", use: ""))
        ]
        let derBase64 = try XCTUnwrap(Data(base64Encoded: derBase64Key))
        let trustEvaluation = TrustEvaluation()

        let result = trustEvaluation.check(serverKeyData: derBase64, against: jwkSet)

        guard case .failure(let error) = result,
              error == .CERT_PIN_MISMATCH else {

            XCTFail("CERT_PIN_MISMATCH error expected.")
            return
        }
    }

    private let derBase64Key = "MIIKYjCCCUqgAwIBAgIQCHqQhfK5cL4DCOKQTxTSzTANBgkqhkiG9w0BAQsFADBPMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMSkwJwYDVQQDEyBEaWdpQ2VydCBUTFMgUlNBIFNIQTI1NiAyMDIwIENBMTAeFw0yMTEwMTMwMDAwMDBaFw0yMjEwMTMyMzU5NTlaMHQxCzAJBgNVBAYTAkRFMRswGQYDVQQIDBJCYWRlbi1Xw7xydHRlbWJlcmcxETAPBgNVBAcTCFdhbGxkb3JmMQ8wDQYDVQQKEwZTQVAgU0UxJDAiBgNVBAMMGyouY2YuZXUxMC5oYW5hLm9uZGVtYW5kLmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMtJPD6ioIz1ughZwF8U8banEOzmI10DnUEoLAywjy2+GA42T7ZRqM4ju5JjWAjKDQgMX6CseQ6mcavvctVam9VIaDxWe/+4iQcgxJvelyFdoG2tGBSiCWIYx3He1CZLJu/JWNyE0q6OIv2u4BEcPYVOuoSZZc2kNUlWUpDHnTSNfMVsPujiBAjufXRGUoq7WaIOz/9jq4aMvMRCWsBKShz88osBN57x9kj5KqWsopCZ3VHyyIDg4W4dJjUXP0BfnQwLCGQCDwCKfHtUNaSh2qzpww3dZhrefdoOFj6LI6qbxnXIAhj6F2K1HC3kaNot1ivfnthIctmhBRoVEDBfMLpNksnDyPM0zfMjEYhur417dBlSmG4JFJvzr9tHzUEf9cEemM2YS3dk6NUrv0sRr8/tQVf2zsmeT0UrjyWGcpwJDAqljSOuT/H9sbxcLqtqwoRirE85hhQVwsaTXlZbwaoobLJtNWrFFyUrdjn6W8XORCk+oM+K0GqEmGd305BSFfOoerW/j8Eh/g6p1She4zG2gf6AY00vER8fn+Tibs0GtnPho6I3EDrOeXd3q2pjxX5/vuj87yMkX8hg1hcY3RORwyrjhD0gHQ9QO+tP74lhcJifb/px99BmzBAhFZEaFWvK6c5Z18oXilMef+DTrsVk7F4HUAdUH2q6dntgFYwDAgMBAAGjggYTMIIGDzAfBgNVHSMEGDAWgBS3a6LqqKqEjHnqtNoPmLLFlXa59DAdBgNVHQ4EFgQUt9N4g5xG7V380RuH/d01ZdlOte4wggK4BgNVHREEggKvMIICq4IbKi5jZi5ldTEwLmhhbmEub25kZW1hbmQuY29tgh8qLnVhYS5jZi5ldTEwLmhhbmEub25kZW1hbmQuY29tgiAqLm1lc2guY2YuZXUxMC5oYW5hLm9uZGVtYW5kLmNvbYIhKi5sb2dpbi5jZi5ldTEwLmhhbmEub25kZW1hbmQuY29tgiB4c3VhYS1hcGkuZXUxMC5oYW5hLm9uZGVtYW5kLmNvbYIiKi54c3VhYS1hcGkuZXUxMC5oYW5hLm9uZGVtYW5kLmNvbYIlYXV0aGVudGljYXRpb24uZXUxMC5oYW5hLm9uZGVtYW5kLmNvbYInKi5hdXRoZW50aWNhdGlvbi5ldTEwLmhhbmEub25kZW1hbmQuY29tgh8qLmNmYXBwcy5ldTEwLmhhbmEub25kZW1hbmQuY29tgkEqLnN1YnNjcmlwdGlvbi1tYW5hZ2VtZW50LWRhc2hib2FyZC5jZmFwcHMuZXUxMC5oYW5hLm9uZGVtYW5kLmNvbYIxKi5vcGVyYXRpb25zY29uc29sZS5jZmFwcHMuZXUxMC5oYW5hLm9uZGVtYW5kLmNvbYIoKi5pbnRlcm5hbC5jZmFwcHMuZXUxMC5oYW5hLm9uZGVtYW5kLmNvbYIvKi5hdWRpdGxvZy12aWV3ZXIuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb22CJCouY2VydC5jZmFwcHMuZXUxMC5oYW5hLm9uZGVtYW5kLmNvbYIeY29ja3BpdC5ldTEwLmhhbmEub25kZW1hbmQuY29tgiphdXRoZW50aWNhdGlvbi5jZXJ0LmV1MTAuaGFuYS5vbmRlbWFuZC5jb22CLCouYXV0aGVudGljYXRpb24uY2VydC5ldTEwLmhhbmEub25kZW1hbmQuY29tMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwgY8GA1UdHwSBhzCBhDBAoD6gPIY6aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VExTUlNBU0hBMjU2MjAyMENBMS00LmNybDBAoD6gPIY6aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VExTUlNBU0hBMjU2MjAyMENBMS00LmNybDA+BgNVHSAENzA1MDMGBmeBDAECAjApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwfwYIKwYBBQUHAQEEczBxMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wSQYIKwYBBQUHMAKGPWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRMU1JTQVNIQTI1NjIwMjBDQTEtMS5jcnQwDAYDVR0TAQH/BAIwADCCAX8GCisGAQQB1nkCBAIEggFvBIIBawFpAHcAKXm+8J45OSHwVnOfY6V35b5XfZxgCvj5TV0mXCVdx4QAAAF8e0dS3wAABAMASDBGAiEAldeVFn8gMhxGYBG+4Rg8dEu5tMjswUoV/epa2eREDI4CIQDmHlsPzrXSNarmkv6Vfn+yoPU+20ZxEtHxmk3hvM8SfgB2AFGjsPX9AXmcVm24N3iPDKR6zBsny/eeiEKaDf7UiwXlAAABfHtHUwEAAAQDAEcwRQIhANXZitXDJTwlSrYJlSbuEbG7c/icUBf0GONF8Ty9BLh4AiAnUAp+WJwY18JV0QwMgVPDBDuVdFLwcZLdPNWgbhsUVwB2AEHIyrHfIkZKEMahOglCh15OMYsbA+vrS8do8JBilgb2AAABfHtHUnkAAAQDAEcwRQIgT+djP0WNmmKpa2Io8/D5STvwMej23RylTYH5TLpBJjcCIQCq7rE6LYtQOBUZIzR4YKexOjKisu+K0gcPmA2ZZ42c9zANBgkqhkiG9w0BAQsFAAOCAQEAbjSRHY9N0YiBSK+Tt7EoABaHWIe6FOPES+Wlxl3jM0I52WowheFRaGUtO+hyF/z8EMD6eesyF83j8mC378EkBqkzdYts4NM2Oa/sUtvt9wg56zPIZjIOXuu4EYcHSlKnSzPR8KIa2wRjqZ6F4kLR5lVUgmGWox21SBfuydrSwyQELuu1ExoHUs8RTpoXGDJXAz1mPo46mzpJub96u0sGgFyjk6ZIu1DLYyBeVK3VI9uypuuH9WkWmI20qx74Cc/sAhohifZhyhp3DWbXzqqnxda0Y+VNym1esevZrTBUrwv9QBh4DuBtkKWOKeoXM8COXFF8efCDi7I+9oGKRrpVhA=="

    private let keyIdentifier = "6H4m650iKAE="
}

private extension String {
    func dataWithHexString() -> Data {
        var hex = self
        var data = Data()
        while !hex.isEmpty {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
}

private extension Data {
    func hexEncodedString() -> String {
        let format = "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
