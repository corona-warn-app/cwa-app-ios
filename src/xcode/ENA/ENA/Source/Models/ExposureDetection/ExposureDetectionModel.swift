//
//  ExposureDetectionModel.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 18.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


struct ExposureDetectionModel {
	let content: [Content]
	
	let help: String
	let hotline: (text: String, number: String)
	let checkButton: String
}


extension ExposureDetectionModel {
	enum Content {
		case headline(text: String)
		case guide(image: UIImage?, text: String)
		case title(text: String)
		case text(text: String)
		case more(text: String, url: URL?)
		case phone(text: String, number: String)
	}
}
