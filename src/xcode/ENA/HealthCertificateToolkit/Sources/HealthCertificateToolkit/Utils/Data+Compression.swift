//
// 🦠 Corona-Warn-App
//

import Foundation
import Compression

extension Data {

    func decompressZLib() throws -> Data {
        let decodedCapacity = 4 * count + 8 * 1024
        let decodedDestinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: decodedCapacity)

        // First 2 bytes needs to be dropped. Please see: https://stackoverflow.com/a/55558641/2585092
        let result = try subdata(in: 2 ..< count).withUnsafeBytes ({ encodedSourceBuffer in
            let typedPointer = encodedSourceBuffer.bindMemory(to: UInt8.self)

            guard let baseAddress = typedPointer.baseAddress else {
                throw HealthCertificateDecodingError.HC_ZLIB_DECOMPRESSION_FAILED
            }

            let read = compression_decode_buffer(
                decodedDestinationBuffer,
                decodedCapacity,
                baseAddress,
                count - 2, nil,
                COMPRESSION_ZLIB
            )

            return Data(bytes: decodedDestinationBuffer, count:read)
        }) as Data

        decodedDestinationBuffer.deallocate()
        return result
    }
}
