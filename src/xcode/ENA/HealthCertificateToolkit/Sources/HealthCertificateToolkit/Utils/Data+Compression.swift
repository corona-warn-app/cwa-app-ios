//
// 🦠 Corona-Warn-App
//

import Foundation
import Compression
import SWCompression

extension Data {

    func decompressZLib() throws -> Data {
        return try ZlibArchive.unarchive(archive: self)
    }

    func compressZLib() -> Data {
        return ZlibArchive.archive(data: self)
    }
}
