//
//  IndicatorView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 04.11.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct DynamicStackView: View {
    /// The key indicating the contents of the dynamic stack
    enum Indicator : String, CaseIterable {
        case altimeter, airspeed, vspeed, attitude, heading, turn
    }
  
    /// The indicators that are visible in the stack; this
    func visibleIndicators() -> [Indicator] {
        return Indicator.allCases.shuffled() // or whatever order you want…
    }
  
    /// Vends a view for the given indicator key
    func indicatorView(for indicator: Indicator) -> some View {
        return Text("Winners Dream!")
        switch indicator {
        case .altimeter:
            return Text("Too High!")
        case .airspeed:
            return Text("Too Fast!")
        case .vspeed:
            return Text("Going Up!")
        case .attitude:
            return Text("Banking!")
        case .heading:
            return Text("Wrong Way!")
        case .turn:
            return Text("Uncoordinated!")
        }
    }
  
    /// Builds the dynamic stack of indicators based on the indicator order returned from `visibleIndicators()`
    var dynamicStack: some View {
        HStack {
            ForEach(visibleIndicators(), id: \.self, content: self.indicatorView(for:))
        }
    }
  
    var body: some View {
        dynamicStack
    }
  
}

