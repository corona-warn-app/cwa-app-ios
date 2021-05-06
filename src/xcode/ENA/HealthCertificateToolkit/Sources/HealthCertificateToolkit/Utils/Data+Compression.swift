//
// 🦠 Corona-Warn-App
//

import Foundation
import Compression

extension Data {

    func decompressZLib() throws -> Data {
        // The maximum output size of the zlib decompression shall be set to 10 MB to protect against zip bomb attacks.
        let tenMBCapacityLimitInByte = 10_485_760 //10 * 1024 * 1024

        let decodedDestinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: tenMBCapacityLimitInByte)

        // First 2 bytes needs to be dropped. Please see: https://stackoverflow.com/a/55558641/2585092
        let result = try subdata(in: 2 ..< count).withUnsafeBytes ({ encodedSourceBuffer in
            let typedPointer = encodedSourceBuffer.bindMemory(to: UInt8.self)

            guard let baseAddress = typedPointer.baseAddress else {
                throw CertificateDecodingError.HC_ZLIB_DECOMPRESSION_FAILED
            }

            let read = compression_decode_buffer(
                decodedDestinationBuffer,
                tenMBCapacityLimitInByte,
                baseAddress,
                count - 2, 
                nil,
                COMPRESSION_ZLIB
            )

            return Data(bytes: decodedDestinationBuffer, count:read)
        }) as Data

        decodedDestinationBuffer.deallocate()
        return result
    }
}
