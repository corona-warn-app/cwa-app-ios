//
//  QRCodeModel.swift
//  QRCodeImage
//
//  Created by Kai-Marcel Teuber on 18.08.21.
//

import Foundation

struct QRCodeModel: Hashable {
    let info: String?
    let body: String
    let identifier: UUID = UUID()
}
