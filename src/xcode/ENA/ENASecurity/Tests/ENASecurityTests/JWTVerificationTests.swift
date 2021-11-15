//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENASecurity

public class JWTVerificationTests: XCTestCase {

    public func test_JWTVerification() {
        for testData in testDatas {
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

    struct TestData {
        let description: String
        let jwkSet: [JSONWebKey]
        let token: String
        let expectedErrorCode: JWTVerificationError?
    }

    private let testDatas = [
        TestData(
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
        TestData(
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
        TestData(
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
        TestData(
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
        TestData(
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
        TestData(
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
}
