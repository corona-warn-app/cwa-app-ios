//
// 🦠 Corona-Warn-App
//

import Foundation

struct JSONWebKey: Codable {
    let x5x: String
    let kid: String
    let alg: String
    let use: String
}
