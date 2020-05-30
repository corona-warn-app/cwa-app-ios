//
//  Flogger.swift
//  ENA
//
//  Created by Dunne, Liam on 24/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import BackgroundTasks

public class Flogger {
	static let shared = Flogger(isOn: true)
	public static func write(_ trace: String, message: String? = nil) {
		shared.write(trace, message: message)
	}
	public static func read() {
		shared.read()
	}
	
	private var isOn: Bool = false
	private var didReset: Bool = false
	private let queue = OperationQueue()
	init(isOn: Bool) {
		self.isOn = isOn
		queue.maxConcurrentOperationCount = 1
		reset()
	}

	private lazy var url: URL = {
		// swiftlint:disable:next force_unwrapping
        return  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("log.txt")
	}()

	public func reset() {
		guard didReset == false else { return }
		didReset = true
		guard FileManager.default.fileExists(atPath: url.path) else { return }
		do {
			try FileManager.default.removeItem(atPath: url.path)
		} catch {
			logError(message: error.localizedDescription)
		}
	}
    public func write(_ trace: String, message: String? = nil) {
		guard isOn else { return }
		let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        var logMessage = "\(timestamp): \(trace)"
		if let message = message { logMessage += "\n\t\(message)" }
		queue.addOperation {
			self.write(logMessage)
		}
    }
    public func read() {
		guard isOn else { return }
        print("#", #line, #function)
        print("########################")
        do {
            let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            print(result)
        } catch {
            print(error)
        }
        print("########################")
    }
    private func write(_ message: String) {
		do {
		let outputMessage = message + "\n"
			guard let data = outputMessage.data(using: String.Encoding.utf8) else { return }
			if FileManager.default.fileExists(atPath: url.path) {
				if let fileHandle = try? FileHandle(forWritingTo: url) {
					fileHandle.seekToEndOfFile()
					fileHandle.write(data)
					fileHandle.closeFile()
				}
			} else {
				try data.write(to: url, options: .atomicWrite)
			}
		} catch {
			logError(message: error.localizedDescription)
		}
    }
}
