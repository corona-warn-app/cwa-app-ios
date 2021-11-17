//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENASecurity

public class JWTVerificationTests: XCTestCase {

    public func test_JWTSetVerification() {
        for testData in jwtSetTestDatas {
            let result = JWTVerification().verify(jwtString: testData.token, against: testData.jwkSet)

            if let expectedError = testData.expectedErrorCode {
                guard case .failure(let error) = result,
                      error == expectedError else {
                          XCTFail("Failed case: '\(testData.description)'. Error expected: \(expectedError)")
                          return
                      }
            } else {
                if case .failure(let error) = result {
                    XCTFail("Failed case: '\(testData.description)' with error: \(error)")
                    return
                }
            }
        }
    }

    public func test_JWTVerification() {
        for testData in jwtTestDatas {
            let pemString = "-----BEGIN PUBLIC KEY-----\(testData.publicKeyBase64)-----END PUBLIC KEY-----"
            guard let pemPublicKey = pemString.data(using: .utf8) else {
                XCTFail("Could not create pem data.")
                return
            }

            let result = JWTVerification().verify(jwtString: testData.token, against: pemPublicKey, and: testData.alg)

            if testData.expectedVerified {
                guard case .success = result else {
                    XCTFail("Success expected")
                    return
                }
            } else {
                guard case .failure = result else {
                    XCTFail("Failure expected")
                    return
                }
            }
        }
    }

    struct JWTSetTestData {
        let description: String
        let jwkSet: [JSONWebKey]
        let token: String
        let expectedErrorCode: JWTVerificationError?
    }

    private let jwtSetTestDatas = [
        JWTSetTestData(
            description: "verifies the JWT signature based on the kid in the header",
            jwkSet: [
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWrMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDUyMloXDTMxMTAyNjEwMDUyMlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIMN3/9b32RulED0quAjfqbJ161DMlEX0vKmRJeKkF9qSvGDh54wY3wvEGzR8KRoIkltp2/OwqUWNCzE3GDDbjAJBgcqhkjOPQQBA0gAMEUCIBGdBhvrxWHgXAidJbNEpbLyOrtgynzS9m9LGiCWvcpsAiEAjeJvDQ03n6NR8ZauecRtxTyXzFx8lv6XA273K05COpI=",
                    kid: "pGWqzB9BzWY=",
                    alg: "ES256",
                    use: "sig"
                ),
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWsMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDYwM1oXDTMxMTAyNjEwMDYwM1owYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEoobPcUO7ndJq0NPPidIKLgZ2pMhC8kaDuwuklXtzOPf31KydNtiMm6cZJUUg0IcjMA0DizEjSb8CywoKpaJJIjAJBgcqhkjOPQQBA0gAMEUCIH6hNfuh1hg2gS867XQc6Lc72PZTa2JzMqwZvQiU70uZAiEAk/72JJM0zsFwixCVf3pXZwdH3R3FhNE3y13H0y2Qvpk=",
                    kid: "F8ElXV0sC2U=",
                    alg: "ES256",
                    use: "sig"
                ),
                JSONWebKey(
                    x5c: "MIIB/jCCAaWgAwIBAgIJANocmV/U2sWtMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDY0NloXDTMxMTAyNjEwMDY0NlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFRBNFvVLdf3L5kNtzEs7qUi4L/p/+yo+JMxE8/DWxZA94OnrgwC9qIBuJdZLdws2kjcJiATMEgOmAujf6UFBRb/z07Pleo3LhUS+AA0xNhAkGetW5qb5d966MPehiyqbGhmivUPE7a6CaHF1vluFufkKw7E3QVGPINZBt4zaj9QIDAQABMAkGByqGSM49BAEDSAAwRQIhALQUIFseqovYowBG4e8PJEyIH4y9HClaiKc6YFjS0gDOAiAs7MrGaHdd5mcQ4RZPvuyrN25EDA+hYFu5CWq1UAO9Ug==",
                    kid: "bGUu3iZsaag=",
                    alg: "RS256",
                    use: "sig"
                )
            ],
            token: "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkY4RWxYVjBzQzJVPSJ9.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDg5MDcyfQ.0wRhcAh--PNgPw5LnRPuierbxFyl7RoCKFADT-N7kSuXOxCUMtzCoVyJaTR9cz-egHC1tk40_-jHo1boUzq0AA",
            expectedErrorCode: nil
        ),
        JWTSetTestData(
            description: "verifies the JWT signature even if there are multiple JWKs with the same kid",
            jwkSet: [
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWrMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDUyMloXDTMxMTAyNjEwMDUyMlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIMN3/9b32RulED0quAjfqbJ161DMlEX0vKmRJeKkF9qSvGDh54wY3wvEGzR8KRoIkltp2/OwqUWNCzE3GDDbjAJBgcqhkjOPQQBA0gAMEUCIBGdBhvrxWHgXAidJbNEpbLyOrtgynzS9m9LGiCWvcpsAiEAjeJvDQ03n6NR8ZauecRtxTyXzFx8lv6XA273K05COpI=",
                    kid: "pGWqzB9BzWY=",
                    alg: "ES256",
                    use: "sig"
                ),
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWsMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDYwM1oXDTMxMTAyNjEwMDYwM1owYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEoobPcUO7ndJq0NPPidIKLgZ2pMhC8kaDuwuklXtzOPf31KydNtiMm6cZJUUg0IcjMA0DizEjSb8CywoKpaJJIjAJBgcqhkjOPQQBA0gAMEUCIH6hNfuh1hg2gS867XQc6Lc72PZTa2JzMqwZvQiU70uZAiEAk/72JJM0zsFwixCVf3pXZwdH3R3FhNE3y13H0y2Qvpk=",
                    kid: "pGWqzB9BzWY=",
                    alg: "ES256",
                    use: "sig"
                )
            ],
            token: "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InBHV3F6QjlCeldZPSJ9.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDg5MDcyfQ.VpFyNk-24S_-TZ8idQBCjzo8-_50xiYSp6XVpFS0e3L0f7YW04Ie8U4hSDPRXqMDnvt-osZayn-wNSy5x7jfyA",
            expectedErrorCode: nil
        ),
        JWTSetTestData(
            description: "rejects the JWT signature if there is no JWK with the same kid",
            jwkSet: [
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWrMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDUyMloXDTMxMTAyNjEwMDUyMlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIMN3/9b32RulED0quAjfqbJ161DMlEX0vKmRJeKkF9qSvGDh54wY3wvEGzR8KRoIkltp2/OwqUWNCzE3GDDbjAJBgcqhkjOPQQBA0gAMEUCIBGdBhvrxWHgXAidJbNEpbLyOrtgynzS9m9LGiCWvcpsAiEAjeJvDQ03n6NR8ZauecRtxTyXzFx8lv6XA273K05COpI=",
                    kid: "pGWqzB9BzWY=",
                    alg: "ES256",
                    use: "sig"
                ),
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWsMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDYwM1oXDTMxMTAyNjEwMDYwM1owYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEoobPcUO7ndJq0NPPidIKLgZ2pMhC8kaDuwuklXtzOPf31KydNtiMm6cZJUUg0IcjMA0DizEjSb8CywoKpaJJIjAJBgcqhkjOPQQBA0gAMEUCIH6hNfuh1hg2gS867XQc6Lc72PZTa2JzMqwZvQiU70uZAiEAk/72JJM0zsFwixCVf3pXZwdH3R3FhNE3y13H0y2Qvpk=",
                    kid: "F8ElXV0sC2U=",
                    alg: "ES256",
                    use: "sig"
                )
            ],
            token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJHVXUzaVpzYWFnPSJ9.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDg5MDcyfQ.HoM8-WOAkUeDz9j2EvK7mjiV8NnB8_1V85hPT69xT4RDzNE6OMFFszWWoHnfXjr6t4e4WI6nJp2dzX24Q6dV1dCdBFlGPQ7Fa_Dw6NZmbSmsT5n0hjtZbaHtt6fk5NS_OW6wLX_-8zlsFVUftg__6HS2lX-I37nttjdKh1jTfHQ",
            expectedErrorCode: .JWT_VER_NO_JWK_FOR_KID
        ),
        JWTSetTestData(
            description: "rejects the JWT signature if the signature simple does not match",
            jwkSet: [
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWrMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDUyMloXDTMxMTAyNjEwMDUyMlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIMN3/9b32RulED0quAjfqbJ161DMlEX0vKmRJeKkF9qSvGDh54wY3wvEGzR8KRoIkltp2/OwqUWNCzE3GDDbjAJBgcqhkjOPQQBA0gAMEUCIBGdBhvrxWHgXAidJbNEpbLyOrtgynzS9m9LGiCWvcpsAiEAjeJvDQ03n6NR8ZauecRtxTyXzFx8lv6XA273K05COpI=",
                    kid: "pGWqzB9BzWY=",
                    alg: "ES256",
                    use: "sig"
                ),
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWsMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDYwM1oXDTMxMTAyNjEwMDYwM1owYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEoobPcUO7ndJq0NPPidIKLgZ2pMhC8kaDuwuklXtzOPf31KydNtiMm6cZJUUg0IcjMA0DizEjSb8CywoKpaJJIjAJBgcqhkjOPQQBA0gAMEUCIH6hNfuh1hg2gS867XQc6Lc72PZTa2JzMqwZvQiU70uZAiEAk/72JJM0zsFwixCVf3pXZwdH3R3FhNE3y13H0y2Qvpk=",
                    kid: "bGUu3iZsaag=",
                    alg: "ES256",
                    use: "sig"
                )
            ],
            token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJHVXUzaVpzYWFnPSJ9.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDg5MDcyfQ.HoM8-WOAkUeDz9j2EvK7mjiV8NnB8_1V85hPT69xT4RDzNE6OMFFszWWoHnfXjr6t4e4WI6nJp2dzX24Q6dV1dCdBFlGPQ7Fa_Dw6NZmbSmsT5n0hjtZbaHtt6fk5NS_OW6wLX_-8zlsFVUftg__6HS2lX-I37nttjdKh1jTfHQ",
            expectedErrorCode: .JWT_VER_SIG_INVALID
        ),
        JWTSetTestData(
            description: "rejects the JWT signature if JWT has no kid",
            jwkSet: [
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWrMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDUyMloXDTMxMTAyNjEwMDUyMlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIMN3/9b32RulED0quAjfqbJ161DMlEX0vKmRJeKkF9qSvGDh54wY3wvEGzR8KRoIkltp2/OwqUWNCzE3GDDbjAJBgcqhkjOPQQBA0gAMEUCIBGdBhvrxWHgXAidJbNEpbLyOrtgynzS9m9LGiCWvcpsAiEAjeJvDQ03n6NR8ZauecRtxTyXzFx8lv6XA273K05COpI=",
                    kid: "pGWqzB9BzWY=",
                    alg: "ES256",
                    use: "sig"
                )
            ],
            token: "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDg5MDcyfQ.SCixwZS8nvd1H_xufhoXuxfhh-zgu1eJZFHab_y7q452FG6qk_OPACmq8hrXa5UeqEh73ZNgIZJJ--e89Drg3A",
            expectedErrorCode: .JWT_VER_NO_KID
        ),
        JWTSetTestData(
            description: "rejects the JWT signature if JWT was signed with an unsupported algorithm",
            jwkSet: [
                JSONWebKey(
                    x5c: "MIIBtzCCAV6gAwIBAgIJANocmV/U2sWrMAkGByqGSM49BAEwYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMB4XDTIxMTAyODEwMDUyMloXDTMxMTAyNjEwMDUyMlowYjELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJXMREwDwYDVQQHDAhXYWxsZG9yZjEPMA0GA1UECgwGU0FQIFNFMRAwDgYDVQQLDAdDV0EgQ0xJMRAwDgYDVQQDDAdjd2EtY2xpMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIMN3/9b32RulED0quAjfqbJ161DMlEX0vKmRJeKkF9qSvGDh54wY3wvEGzR8KRoIkltp2/OwqUWNCzE3GDDbjAJBgcqhkjOPQQBA0gAMEUCIBGdBhvrxWHgXAidJbNEpbLyOrtgynzS9m9LGiCWvcpsAiEAjeJvDQ03n6NR8ZauecRtxTyXzFx8lv6XA273K05COpI=",
                    kid: "pGWqzB9BzWY=",
                    alg: "ES256",
                    use: "sig"
                )
            ],
            token: "eyJhbGciOiJFUzM4NCIsInR5cCI6IkpXVCIsImtpZCI6InBHV3F6QjlCeldZPSJ9.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDg5MDcyfQ.AAAAAAAAAAAAAAAAAAAAADk6QRRZqQzqKsU7LJrwD5SMjnQTO7fJlrTEsESGM0IXAAAAAAAAAAAAAAAAAAAAAGot13odJki5XVHEA8uBAwSq-3HSAVQnM72xoku2RHqf",
            expectedErrorCode: .JWT_VER_ALG_NOT_SUPPORTED
        )
    ]

    struct JWTTestData {
        let alg: String
        let publicKeyBase64: String
        let token: String
        let expectedVerified: Bool
    }

    let jwtTestDatas = [
        JWTTestData(
            alg: "ES256",
            publicKeyBase64: "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAExdBE4qp1wmt6uHy+pUc5CoUor6IelJeb2oZeeHz57pApfJlaM4BmvLuBqtqQYJymPjj7IhCqzzJhqlYVi7AJvQ==",
            token: "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InRlc3QifQ.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDE4ODQxfQ.xhXURyWJy8QBDwZf7tE4_2jktWIm-hW64nakrkZJytXY17tzEXOi9_9YINPBRIpqQp8cmDfmAQZLvCrtT0Hr5Q",
            expectedVerified: true
        ),
        JWTTestData(
            alg: "ES256",
            publicKeyBase64: "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE9f390ezUBOpIFipddHLBgsE0lgDV5jeqwC6gUkTmvd3G2y9zB30+7DOGbM+95NxkXJKVcGWb5uujG/0QN2xZhg==",
            token: "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InRlc3QifQ.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDE4ODQxfQ.xhXURyWJy8QBDwZf7tE4_2jktWIm-hW64nakrkZJytXY17tzEXOi9_9YINPBRIpqQp8cmDfmAQZLvCrtT0Hr5Q",
            expectedVerified: false
        ),
        JWTTestData(
            alg: "RS256",
            publicKeyBase64: "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDqirWUTH+AhYEpkLe457rmP8NTmy8WTdP579gWXnkn8wXfsAyNBNQQ9PkdBy4+jPIOl+7BwCLdTWjZsrG0YnrND7bGTsJ0B0NWKUotLLQdNzELP1ObFlKnp02wsaz8gl1ne4GH4Sb4JsDgubEDOrxrAmy92IP2+pTJ8JSWbLxpcwIDAQAB",
            token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InRlc3QifQ.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDE5ODk3fQ.iRBidsQlD84J62sVwQjPEwVMyJle0daIIqRStthy_2S9eMQeFu1F5lDH9dSKwwIFMJl0wUp18-KKNHsLe7VymKP9OR6hrU5s3SiBKRfVsPSp_LImw0WMI8H-1ZIVOfkCy5rY86sPbmj62i373wiaXPcNohQpX8E1jARJ6-ZN8Fk",
            expectedVerified: true
        ),
        JWTTestData(
            alg: "RS256",
            publicKeyBase64: "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCwo9zd+9jseyt1NvjUdzVEvG1paGuHGc9U6WVi3F9ebKFbic3prLQx5urr5OIQ/PzCO92pDL1nBNx6nVK1O7RdNUDrtfoHmLSMWcwtN81H9qZizWlxd5foapUf/9sxmiunEUIoHsHSWFWyHbO/Pu6DZsmFtzNEfv0H1/HDe031XQIDAQAB",
            token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InRlc3QifQ.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDE5ODk3fQ.iRBidsQlD84J62sVwQjPEwVMyJle0daIIqRStthy_2S9eMQeFu1F5lDH9dSKwwIFMJl0wUp18-KKNHsLe7VymKP9OR6hrU5s3SiBKRfVsPSp_LImw0WMI8H-1ZIVOfkCy5rY86sPbmj62i373wiaXPcNohQpX8E1jARJ6-ZN8Fk",
            expectedVerified: false
        ),
        JWTTestData(
            alg: "PS256",
            publicKeyBase64: "MIIBIDALBgkqhkiG9w0BAQoDggEPADCCAQoCggEBAN7PJDuvq9mEMQzF4rgV1IB83+e5nVX3R7bXjpemxPFXvNfZIaerHUsSbmMjnNDfoquL4g9Ue+31Ky8YSaAdqM4qnMQDSdK6QEUAFOcL8XPqVTdSWBnF4aAAkBR+E9fVp3O3j+om0P9suy5KKWXVguM0p6xBnSqgbXdWoM/pfeXV2R4DAr5Oo0tyVT8tIM6qXChjavvUgvYzB3zG5MIlJKTHq8oCGNhsmHUc9TKoFM5vfqiNpxz8z2f1MnXCF5oI3RW9MT8/ej4pYwFiU9Aux67Z3otnWWzLPy3XWUMBXENeZO9NEXlmD5ezrvPMcZZ2YIpRdgn81mJv7RHkoM27Vf0CAwEAAQ==",
            token: "eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDMzODM3fQ.mlmk-qbCgXklVL4G9N0UHZIfHtzoVHZPhCC1VbZyHn3xNerGKPYwCC7IIs8S34MGBZmBI3-uC3BJfQryeWxrkgX10WdmaEMArUURLk3F745iN8ar3cpPcwDUyZlzcxvVuT8dP9nl8k_6ua3U1G8y_qhZVPAcql4xhYWhfiefzF9qh4MdhX1HAuVKHngCr3K-1dTznLuBeQQq_2nzsGie7fnoiWNHHFR0dec_rTEmWFFSnU7muH1kfMb-tGUMJ_jw3dn88jjB3vYrlrg8HuKH85z8wA8vGUV0CpLhOqHVp_Haa5nPtnjoa3gX4ygBW2dWbY0guZBlcl9nqY2S-IRjtQ",
            expectedVerified: true
        ),
        JWTTestData(
            alg: "PS256",
            publicKeyBase64: "MIIBIDALBgkqhkiG9w0BAQoDggEPADCCAQoCggEBAMArJnssu9aXIDN3i0o7lh0yZzkG60lQW9nKwy0kQBGozBsKORKuij1fJZ/NV0MVezV4X7HK9Jx7eW+kT6Vzuvgjxu0NiLSBhnyyXGPbq9Vyamrl4hOL8hOkgItV8YS2cu5lIpvDnE9YStiVPRgMh4p78BvhUNnQPDTYt2jZHP6Z5+yrQfFbp+LuXnJUzM7ECzyMa+dT9fSvN7ZOAwkVwPgk8NUmWhwemlWIOGkWDU0ASCKlj79+9dRK2TRXAUv2vuJZRnvkifV0+z4/LWuFpL0kWkPahkK3832zh8HvdsZm41qqFJQjF4atcT6gstyS2RrWnkIBHTBPY6STLxXlz28CAwEAAQ==",
            token: "eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6IldvcmxkIiwiaWF0IjoxNjM1NDMzODM3fQ.mlmk-qbCgXklVL4G9N0UHZIfHtzoVHZPhCC1VbZyHn3xNerGKPYwCC7IIs8S34MGBZmBI3-uC3BJfQryeWxrkgX10WdmaEMArUURLk3F745iN8ar3cpPcwDUyZlzcxvVuT8dP9nl8k_6ua3U1G8y_qhZVPAcql4xhYWhfiefzF9qh4MdhX1HAuVKHngCr3K-1dTznLuBeQQq_2nzsGie7fnoiWNHHFR0dec_rTEmWFFSnU7muH1kfMb-tGUMJ_jw3dn88jjB3vYrlrg8HuKH85z8wA8vGUV0CpLhOqHVp_Haa5nPtnjoa3gX4ygBW2dWbY0guZBlcl9nqY2S-IRjtQ",
            expectedVerified: false
        )
    ]
}
