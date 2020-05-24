//
//  Array.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 22.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation


extension Array {
	public func first<T>(ofType type: T.Type) -> T? {
		return first(where: { $0 is T }) as? T
	}
	
	public func firstIndex<T>(ofType type: T.Type) -> Int? {
		return firstIndex(where: { $0 is T })
	}

	public func last<T>(ofType type: T.Type) -> T? {
		return last(where: { $0 is T }) as? T
	}
	
	public func lastIndex<T>(ofType type: T.Type) -> Int? {
		return lastIndex(where: { $0 is T })
	}
	
	public func filter<T>(ofType type: T.Type) -> [T] {
		return filter({ $0 is T }) as? [T] ?? []
	}
	
	public func contains<T>(type: T.Type) -> Bool {
		return contains(where: { $0 is T })
	}
}
