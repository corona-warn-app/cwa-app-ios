//
// 🦠 Corona-Warn-App
//

import Foundation
import AudioToolbox
import AnyCodable
import jsonlogic

enum ParameterType {
	static let number = "number"
	static let string = "string"
	static let localDate = "localDate"
	static let localDateTime = "localDateTime"
	static let utcDate = "utcDate"
	static let utcDateTime = "utcDateTime"
}

enum UITextType {
	static let string = "string"
	static let plural = "plural"
	static let systemTimeDependent = "system-time-dependent"
}

struct DCCUITextParameter {
	let type: String
	let value: Any
}

struct DCCUIText: Codable {
	let type: String
	let quantity: Int?
	let quantityParameterIndex: Int?
	let functionName: String?
	let localizedText: [String: AnyCodable]?
	let parameters: AnyCodable

	func localized(languageCode: String? = Locale.current.languageCode) -> String? {
		switch type {
		case UITextType.string:
			return localizedSingleFormatText(languageCode: languageCode)
		case UITextType.plural:
			return localizedPluralFormatText(languageCode: languageCode)
		case UITextType.systemTimeDependent:
			return localizedSystemTimeDependentFormatText(languageCode: languageCode)
		default:
			return nil
		}
	}
	
	func localizedSingleFormatText(languageCode: String?) -> String? {
		var formatText = ""
		
		// use language code, if there is no property for the language code, en shall be used
		if let localizedFormatText = localizedText?[languageCode ?? "en"]?.value as? String {
			formatText = localizedFormatText
		} else if let fallbackLocalizedFormatText = localizedText?["de"]?.value as? String { // if en is not available, de shall be used
			formatText = fallbackLocalizedFormatText
		} else {
			return nil
		}
		
		// replacing %s with %@, %1$s with %1$@ and so on
		formatText = formatText.replacingOccurrences(of: "%(\\d\\$)?s", with: "%$1@", options: NSString.CompareOptions.regularExpression, range: nil)
		
		if let parameters = parameters.value as? [DCCUITextParameter] {
			if parameters.isEmpty {
				// regular text without placeholders
				return formatText
			} else { // regular text with placeholder
				// text shall be determined by passing formatText and formatParameters to a printf-compatible format function
				return formattedTextWithParameters(formatText: formatText, parameters: parameters)
			}
		} else {
			// regular text without placeholders
			return formatText
		}
	}
	
	func localizedPluralFormatText(languageCode: String?) -> String? {
		var formatText: [String: String] = [:]
		
		// use language code, if there is no property for the language code, en shall be used
		if let localizedFormatText = localizedText?[languageCode ?? "en"]?.value as? [String: String] {
			formatText = localizedFormatText
		} else if let fallbackLocalizedFormatText = localizedText?["de"]?.value as? [String: String] { // if en is not available, de shall be used
			formatText = fallbackLocalizedFormatText
		} else {
			return nil
		}
		
		if let parameters = parameters.value as? [DCCUITextParameter] {
			if parameters.isEmpty {
				// text without parameters
				if let textDescriptorQuantity = quantity {
					return quantityBasedFormatText(formatText: formatText, quantity: textDescriptorQuantity)
				}
			} else {
				// quantity shall be set to the value of textDescriptor.quantity
				if let textDescriptorQuantity = quantity {
					// text shall be determined by passing formatTexts and formatParameters to a quantity-depending printf-compatible format function by using quantity
					return formattedTextWithParameters(formatText: quantityBasedFormatText(formatText: formatText, quantity: textDescriptorQuantity) ?? "", parameters: parameters)
				} else {
					// Otherwise quantity shall be set to the element of formatParameters at the index described by textDescriptor.quantityParameterIndex.
					if let parameterIndex = quantityParameterIndex {
						if let quantityValue = parameters[parameterIndex].value as? Int {
							// text shall be determined by passing formatTexts and formatParameters to a quantity-depending printf-compatible format function by using quantity
							return formattedTextWithParameters(formatText: quantityBasedFormatText(formatText: formatText, quantity: quantityValue) ?? "", parameters: parameters)
						}
					}
				}
			}
		}
		
		return nil
	}

	func localizedSystemTimeDependentFormatText(languageCode: String?) -> String? {
		let service = CCLService()
		guard let parameters = parameters.value as? [String: AnyDecodable], let functionName = functionName else {
			return nil
		}
		
		do {
			// newTextDescriptor shall be determined by calling Calling a CCL API with JsonFunctions.
			let newDCCUIText: DCCUIText = try service.evaluateFunction(name: functionName, parameters: parameters)
			return newDCCUIText.localized(languageCode: languageCode)
		} catch {
			Log.error("Unable to create newTextDescriptor - DCCUIText", error: error)
			return nil
		}
	}

	func formattedTextWithParameters(formatText: String, parameters: [DCCUITextParameter]) -> String {
		let parsedParameters = parameters.map { parseFormatParameter(parameter: $0) }
		return String(format: formatText, parsedParameters)
	}
	
	func quantityBasedFormatText(formatText: [String: String], quantity: Int) -> String? {
		// work around for stringsdict, return key for format text
		let keyFormatText = String(format: NSLocalizedString("DCC_UIText_plural", tableName: "DCCUIText", comment: ""), quantity)
		let quantitySpecificFormatText = formatText[keyFormatText]
		// replacing %s with %@, %1$s with %1$@ and so on
		return quantitySpecificFormatText?.replacingOccurrences(of: "%(\\d\\$)?s", with: "%$1@", options: NSString.CompareOptions.regularExpression, range: nil)
	}
	
	func parseNumber(value: Any) -> Any? {
		if let intValue = value as? Int {
			return intValue
		} else if let doubleValue = value as? Double {
			return doubleValue
		} else {
			return nil
		}
	}
	
	func parseFormatParameter(parameter: DCCUITextParameter) -> Any? {
		let dateFormatter = ISO8601DateFormatter()
		let outputDateFormatter = DateFormatter()
		outputDateFormatter.timeZone = .utcTimeZone

		var date = Date()
		var stringValue: String = ""
		
		// if entry.type is not a number
		if parameter.type != ParameterType.number, let value = parameter.value as? String {
			stringValue = value
		}

		// if entry.type is a date
		if parameter.type == ParameterType.localDate ||
			parameter.type == ParameterType.localDateTime ||
			parameter.type == ParameterType.utcDate ||
			parameter.type == ParameterType.utcDateTime {
			if let formattedDate = dateFormatter.date(from: stringValue) {
				date = formattedDate
			} else {
				return nil
			}
		}
		
		switch parameter.type {
		case ParameterType.number:
			// entry.value shall be treated as a numeric value
			return parseNumber(value: parameter.value)
		case ParameterType.localDate:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (without time information) in local time zone
			return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
		case ParameterType.localDateTime:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (with time information) in local time zone
			return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
		case ParameterType.utcDate:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (without time information) in UTC
			outputDateFormatter.dateStyle = .short
			outputDateFormatter.timeStyle = .none
			return outputDateFormatter.string(from: date)
		case ParameterType.utcDateTime:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (with time information) in UTC
			outputDateFormatter.dateStyle = .short
			outputDateFormatter.timeStyle = .short
			return outputDateFormatter.string(from: date)
		default:
			// otherwise, entry.value shall be treated as a string
			return stringValue
		}
	}
}