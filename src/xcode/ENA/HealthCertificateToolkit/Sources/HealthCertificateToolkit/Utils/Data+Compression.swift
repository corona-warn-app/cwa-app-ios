//
// 🦠 Corona-Warn-App
//

import Foundation
import Compression
import SWCompression

enum ZLibDecompressError: Error {
    case bindMemoryError
    case decompressionFailedError
}

extension Data {

    func decompressZLib() throws -> Data {
            // The maximum output size of the zlib decompression shall be set to 10 MB to protect against zip bomb attacks.
            let tenMBCapacityLimitInByte = 10_485_760 // 10 * 1024 * 1024

            let decodedDestinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: tenMBCapacityLimitInByte)

            // First 2 bytes needs to be dropped. Please see: https://stackoverflow.com/a/55558641/2585092
            let result = try subdata(in: 2 ..< count).withUnsafeBytes({ encodedSourceBuffer in
                let typedPointer = encodedSourceBuffer.bindMemory(to: UInt8.self)

                guard let baseAddress = typedPointer.baseAddress else {
                    throw ZLibDecompressError.bindMemoryError
                }

                let read = compression_decode_buffer(
                    decodedDestinationBuffer,
                    tenMBCapacityLimitInByte,
                    baseAddress,
                    count - 2,
                    nil,
                    COMPRESSION_ZLIB
                )

                return Data(bytes: decodedDestinationBuffer, count: read)
            }) as Data

            decodedDestinationBuffer.deallocate()

            guard !result.isEmpty else {
                throw ZLibDecompressError.decompressionFailedError
            }
            return result
        }

    func compressZLib() -> Data {
        // We use ZlibArchive because it produces a zlib header.
        // The iOS library does not do that.
        // Please see here: https://stackoverflow.com/questions/35279687/ios-compression-encode-buffer-doesnt-include-zlib-header/35280070
        return ZlibArchive.archive(data: self)
    }
}
