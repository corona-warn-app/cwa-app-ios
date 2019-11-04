//
//  ContentView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 25.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let hsize: CGFloat = 180
    let vsize: CGFloat = 80
    let border: CGFloat = 1
    let fontsize: CGFloat = 26
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Text("Andreas Vogel")
                    .font(.system(size: 26))
                    .foregroundColor(Color.white)
                    .frame(width: hsize, height: vsize, alignment: .center)
                    .background(Color.appColor(0))
                    .cornerRadius(8)
                    
                Text("John Appleseed")
                    .font(.system(size: 26))
                    .foregroundColor(Color.white)
                    .frame(width: hsize, height: vsize, alignment: .center)
                    .background(Color.appColor(1))
                    .cornerRadius(8)
                    
            } .padding(.bottom, 10)
            HStack(spacing: 10) {
                Text("Andreas Vogel")
                    .font(.system(size: 26))
                    .foregroundColor(Color.white)
                    .frame(width: hsize, height: vsize, alignment: .center)
                    .background(Color.appColor(3))
                    .cornerRadius(8)
                Text("John Appleseed")
                    .font(.system(size: 26))
                    .foregroundColor(Color.white)
                    .frame(width: hsize, height: vsize, alignment: .center)
                    .background(Color.appColor(4))
                    .cornerRadius(8)
            } .padding(.bottom, 10)
            
        } //.scaledToFill() .offset(x:0,y:0)
        
    }
}

// https://iosexample.com/the-missing-swiftui-collection-view/

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
