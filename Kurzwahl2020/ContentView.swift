//
//  ContentView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 25.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// Geometry          :width , height        View Height
// Phone SE          : 158  , 89,33         552
// iPhone 8          : 185.5, 105.833       647
// iPhone 11         : 205  , 134.333       818
// iPhone 11 Pro     : 185.5, 120.333       734
// iPhone 11 Pro max : 205  , 134.333       818        


import SwiftUI

struct ContentView: View {
    //let hsize: CGFloat = 180
    //let vsize: CGFloat = 80
    let border: CGFloat = 1
    let fontsize: CGFloat = 26
    let maxHeight: CGFloat = 105.833333
    
    struct DynamicStackView: View {
        /// The key indicating the contents of the dynamic stack
        enum Indicator : String, CaseIterable {
            case row1, row2, row3, row4, row5, row6, row7, row8
        }
        
        
        // draw one tile
        fileprivate func tile(_ name: String, withTileNumber: Int, _ height: CGFloat, _ width: CGFloat) -> some View {
            return Text(name)
                .font(.system(size: 26))
                .foregroundColor(Color.white)
                .frame(width: width, height: height, alignment: .center)
                .background(Color.appColor(withTileNumber))
                .cornerRadius(5)
        }
        
        
        fileprivate func xxx (geometry: GeometryProxy) -> (){
            
        }
        
        
        
        // draw a HStack with two tiles
        fileprivate func hstackTiles(_ lineNumber: Int, _ geometry: GeometryProxy) -> some View {
            let hsize = geometry.size.width / 2 - 2
            var vsize = geometry.size.height / 6 - 2
            if vsize > maxHeight {
                vsize = maxHeight
            }
            return HStack(spacing: 2) {
                tile("John Appleseed", withTileNumber: lineNumber * 2, vsize, hsize)
                tile("Andreas Vogel", withTileNumber: lineNumber * 2 + 1, vsize, hsize)
            } .padding(.bottom, 2)
        }
        
        
        
        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    //ForEach(visibleIndicators(), id: \.self, content: self.indicatorView(for:))
                    self.hstackTiles(0, geometry)
                    self.hstackTiles(1, geometry)
                    self.hstackTiles(2, geometry)
                    self.hstackTiles(3, geometry)
                    self.hstackTiles(4, geometry)
                    self.hstackTiles(5, geometry)
                } .scaledToFill() .offset(x:0,y:0)
            }
        }
    }
    
    // https://iosexample.com/the-missing-swiftui-collection-view/
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
