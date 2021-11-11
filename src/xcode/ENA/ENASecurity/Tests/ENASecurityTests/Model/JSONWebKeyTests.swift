//
// 🦠 Corona-Warn-App
//

import XCTest
import ASN1Decoder
@testable import ENASecurity

class JSONWebKeyTests: XCTestCase {

    func test_PublicKeyAccess() {
        for testData in testDatas {
            guard let publicKey = testData.webKey.publicKey(),
                  let publicKeyData = testData.webKey.publicKeyData() else {
                XCTFail("PublicKey expexted.")
                return
            }
            XCTAssertEqual(publicKey.algName, testData.type)
            XCTAssertEqual(publicKey.derEncodedKey?.base64EncodedString(), testData.expectedPublicKeyBase64)
            XCTAssertEqual(publicKeyData.base64EncodedString(), testData.expectedPublicKeyBase64)
        }
    }

    private struct TestData {
        let type: String
        let webKey: JSONWebKey
        let expectedPublicKeyBase64: String
    }

    private let testDatas = [
        TestData(
            type: "ecPublicKey",
            webKey: JSONWebKey(
                x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWrMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDUyMloXDTMxMTAyNjEwMDUyMlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIMN3/9b32RulED0quAjfqbJ161DMlEX0vKmRJeKkF9qSvGDh54wY3wvEGzR8KRoIkltp2/OwqUWNCzE3GDDbjAJBgcqhkjOPQQBA0gAMEUCIBGdBhvrxWHgXAidJbNEpbLyOrtgynzS9m9LGiCWvcpsAiEAjeJvDQ03n6NR8ZauecRtxTyXzFx8lv6XA273K05COpI=",
                kid: "pGWqzB9BzWY=",
                alg: "ES256",
                use: "sig"
            ),
            expectedPublicKeyBase64: "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIMN3/9b32RulED0quAjfqbJ161DMlEX0vKmRJeKkF9qSvGDh54wY3wvEGzR8KRoIkltp2/OwqUWNCzE3GDDbg=="
        ),
        TestData(
            type: "rsaEncryption",
            webKey: JSONWebKey(
                x5c: "MIIB/jCCAaWgAwIBAgIJANocmV/U2sWtMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDY0NloXDTMxMTAyNjEwMDY0NlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFRBNFvVLdf3L5kNtzEs7qUi4L/p/+yo+JMxE8/DWxZA94OnrgwC9qIBuJdZLdws2kjcJiATMEgOmAujf6UFBRb/z07Pleo3LhUS+AA0xNhAkGetW5qb5d966MPehiyqbGhmivUPE7a6CaHF1vluFufkKw7E3QVGPINZBt4zaj9QIDAQABMAkGByqGSM49BAEDSAAwRQIhALQUIFseqovYowBG4e8PJEyIH4y9HClaiKc6YFjS0gDOAiAs7MrGaHdd5mcQ4RZPvuyrN25EDA+hYFu5CWq1UAO9Ug==",
                kid: "bGUu3iZsaag=",
                alg: "RS256",
                use: "sig"
            ),
            expectedPublicKeyBase64: "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFRBNFvVLdf3L5kNtzEs7qUi4L/p/+yo+JMxE8/DWxZA94OnrgwC9qIBuJdZLdws2kjcJiATMEgOmAujf6UFBRb/z07Pleo3LhUS+AA0xNhAkGetW5qb5d966MPehiyqbGhmivUPE7a6CaHF1vluFufkKw7E3QVGPINZBt4zaj9QIDAQAB"
        ),
        TestData(
            type: "rsaSsaPss",
            webKey: JSONWebKey(
                x5c: "MIICiTCCAi4CFE1j4zu8fwdXVFAfuF1BTaXF+/wYMAoGCCqGSM49BAMCMGIxCzAJBgNVBAYTAkRFMQswCQYDVQQIDAJCVzERMA8GA1UEBwwIV2FsbGRvcmYxDzANBgNVBAoMBlNBUCBTRTEQMA4GA1UECwwHQ1dBIENMSTEQMA4GA1UEAwwHY3dhLWNsaTAeFw0yMTEwMjgxNDQ0NTdaFw0zMTEwMjYxNDQ0NTdaMGIxCzAJBgNVBAYTAkRFMQswCQYDVQQIDAJCVzERMA8GA1UEBwwIV2FsbGRvcmYxDzANBgNVBAoMBlNBUCBTRTEQMA4GA1UECwwHQ1dBIENMSTEQMA4GA1UEAwwHY3dhLWNsaTCCASAwCwYJKoZIhvcNAQEKA4IBDwAwggEKAoIBAQDezyQ7r6vZhDEMxeK4FdSAfN/nuZ1V90e2146XpsTxV7zX2SGnqx1LEm5jI5zQ36Kri+IPVHvt9SsvGEmgHajOKpzEA0nSukBFABTnC/Fz6lU3UlgZxeGgAJAUfhPX1adzt4/qJtD/bLsuSill1YLjNKesQZ0qoG13VqDP6X3l1dkeAwK+TqNLclU/LSDOqlwoY2r71IL2Mwd8xuTCJSSkx6vKAhjYbJh1HPUyqBTOb36ojacc/M9n9TJ1wheaCN0VvTE/P3o+KWMBYlPQLseu2d6LZ1lsyz8t11lDAVxDXmTvTRF5Zg+Xs67zzHGWdmCKUXYJ/NZib+0R5KDNu1X9AgMBAAEwCgYIKoZIzj0EAwIDSQAwRgIhANCsXgfP4FQ5zfq7fx/OgZDBdRmjKSoe2OCIfX1DgoC1AiEAjEDcIdERLgpV6Fgt+ds95IfNP6C+u02hoRFaIqBEquE=",
                kid: "DF8FkiQwmd0=",
                alg: "RS256",
                use: "sig"
            ),
            expectedPublicKeyBase64: "MIIBIDALBgkqhkiG9w0BAQoDggEPADCCAQoCggEBAN7PJDuvq9mEMQzF4rgV1IB83+e5nVX3R7bXjpemxPFXvNfZIaerHUsSbmMjnNDfoquL4g9Ue+31Ky8YSaAdqM4qnMQDSdK6QEUAFOcL8XPqVTdSWBnF4aAAkBR+E9fVp3O3j+om0P9suy5KKWXVguM0p6xBnSqgbXdWoM/pfeXV2R4DAr5Oo0tyVT8tIM6qXChjavvUgvYzB3zG5MIlJKTHq8oCGNhsmHUc9TKoFM5vfqiNpxz8z2f1MnXCF5oI3RW9MT8/ej4pYwFiU9Aux67Z3otnWWzLPy3XWUMBXENeZO9NEXlmD5ezrvPMcZZ2YIpRdgn81mJv7RHkoM27Vf0CAwEAAQ=="
        )
    ]
}
