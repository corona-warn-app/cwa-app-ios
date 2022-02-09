//
// 🦠 Corona-Warn-App
//

import WidgetKit
import SwiftUI
import Intents
import CoreImage.CIFilterBuiltins

struct ENAProvider : TimelineProvider {
	typealias Entry = ENATimelineEntry
	
	func placeholder(in context: Self.Context) -> Self.Entry {
		return ENATimelineEntry()
	}
	
	func getSnapshot(in context: Self.Context, completion: @escaping (Self.Entry) -> Void) {
		let entry = ENATimelineEntry()
		completion(entry)
	}

	func getTimeline(in context: Self.Context, completion: @escaping (Timeline<Self.Entry>) -> Void) {
		let entry = ENATimelineEntry()
		let updateTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
		
		completion(Timeline(entries: [entry], policy: .after(updateTime!)))
	}
	
}

struct ENATimelineEntry : TimelineEntry {
	let date = Date()
}

struct ENA_WidgetEntryView: View {
	let context = CIContext()
	let filter = CIFilter.qrCodeGenerator()

    var body: some View {
		if let vaccinationCertificateData = UserDefaults(suiteName: "group.de.rki.coronawarnapp")?.string(forKey: "vaccinationCertificateData") {
			VStack {
				GeometryReader { g in
					if let qrCodeImage = generateQRCode(from: vaccinationCertificateData, displaySize: g.size) {
						Image(uiImage: qrCodeImage)
							.interpolation(.none)
							.resizable()
							.scaledToFit()
					} else {
						Text("Invalid QR code!")
					}
				}
			}
		} else {
			VStack {
				Text("No certificate found!")
			}
		}
    }
	
	func generateQRCode(from string: String, displaySize: CGSize) -> UIImage? {
		filter.message = Data(string.utf8)

		if let outputImage = filter.outputImage {
			let scaleX = displaySize.width / 2 / outputImage.extent.size.width
			let scaleY = displaySize.height / 2 / outputImage.extent.size.height

			/// Scale image
			let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
			
			if let cgimg = context.createCGImage(transformedImage, from: outputImage.extent) {
				return UIImage(cgImage: cgimg)
			}
		}

		return nil
	}
}

@main
struct ENA_Widget: Widget {
    let kind: String = "ENA_Widget"

    var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: ENAProvider()) { entry in
			ENA_WidgetEntryView()
			
		}
		.configurationDisplayName("Certificate Display")
		.description("Shows the preferred person's certificate.")
		.supportedFamilies([.systemSmall])
                
    }
}

struct ENA_Widget_Previews: PreviewProvider {
	static var previews: some View {
		ENA_WidgetEntryView()
			.previewContext(WidgetPreviewContext(family: .systemSmall))
	}
}
