//
//  KurzwahlView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 30.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import QGrid

let fontsize: CGFloat = 26

struct KurzwahlView: View {
    var body: some View {
        GeometryReader { geometry in
            //Spacer()
            QGrid(Storage.people,
                  columns: 2,
                  vSpacing: 2,
                  hSpacing: 2,
                  vPadding: 0,
                  hPadding: 0 ) { GridCell(person: $0,
                                           height: geometry.size.height / 6 ,
                                           width: geometry.size.width / 2 ) }
            
        } //.padding(.bottom, -1)
        //.edgesIgnoringSafeArea(.bottom)
    } //.background(Color.white)
}


struct KurzwahlView_Previews: PreviewProvider {
    static var previews: some View {
        KurzwahlView() .environment(\.colorScheme, .dark)
    }
}


struct GridCell: View {
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
                .background(Color.blue)
        }.cornerRadius(8)
    }
}
