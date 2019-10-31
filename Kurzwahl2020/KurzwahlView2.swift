//
//  KurzwahlView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 30.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import QGrid

struct KurzwahlView2: View {
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                //Spacer()
                QGrid(Storage.people,
                      columns: 2,
                      vSpacing: 2,
                      hSpacing: 2,
                      vPadding: 0,
                      hPadding: 0 ) { GridCell2(person: $0,
                                                height: geometry.size.height / 6 ,
                                                width: geometry.size.width / 2 ) }
                
            } //.padding(.bottom, -1)
            //.edgesIgnoringSafeArea(.bottom)
        }
    }
}


struct KurzwahlView2_Previews: PreviewProvider {
    static var previews: some View {
        KurzwahlView2() .environment(\.colorScheme, .dark)
    }
}


struct GridCell2: View {
    var person: Person
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        VStack {
            Text(person.firstName + " " + person.lastName)
                .font(.system(size: fontsize))
                .foregroundColor(Color.white)
                .frame(width: width, height: height, alignment: .center)
                //.border(Color.gray, width: bordersize)
                .background(Color.red)
        }.cornerRadius(8)
    }
}

