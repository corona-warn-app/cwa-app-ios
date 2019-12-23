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
    @State private var selection = 0
    
    var body: some View {
        
        TabView(selection: $selection) {
            GeometryReader { geometry in
                //Spacer()
                QGrid(Storage.people,
                      columns: 2,
                      vSpacing: 2,
                      hSpacing: 2,
                      vPadding: 0,
                      hPadding: 0 ) { GridCell(person: $0,
                                               height: geometry.size.height / 6 - 2,
                                               width: geometry.size.width / 2 - 2,
                                               pageIndex: 0 )
                }
            }
            .tabItem {
                VStack {
                    Image("first")
                    Text("First")
                }
            }
            .tag(0)
            GeometryReader { geometry in
                QGrid(Storage.people,
                      columns: 2, vSpacing: 2, hSpacing: 2,
                      vPadding: 0, hPadding: 0 )
                { GridCell(person: $0,
                           height: geometry.size.height / 6 - 2 ,
                           width: geometry.size.width / 2 - 2 ,
                           pageIndex: 12 )
                }
            }
            .tabItem {
                VStack {
                    Image("second")
                    Text("2nd")
                }
            }
            .tag(1)
            
//            GeometryReader { geometry in
//                QGrid(Storage.people,
//                      columns: 2, vSpacing: 2, hSpacing: 2,
//                      vPadding: 0, hPadding: 0 )
//                { GridCell(person: $0,
//                           height: geometry.size.height / 6 - 2 ,
//                           width: geometry.size.width / 2 - 2 ,
//                           pageIndex: 6 )
//                }
//            }
//            .tabItem {
//                VStack {
//                    Image("first")
//                    Text("3rd")
//                }
//            }
//            .tag(2)
            
            //NavigationLink("Hallo", destination: KurzwahlView2())
            //.edgesIgnoringSafeArea(.bottom)
        }
    }
}



var AssetColorList: [String] = [
    "OrangeFF9500","Darkblue00398E", "RedFF3A2D",  "RedAC193D",
    "Green008A00", "OrangeD24726", "Green00A600", "Blue2E8DEF",
    "Darkgrey6E6E6E", "lightGreyAEAEAE", "DarkViolet5856D6", "grey8E8E8E",
    "Darkblue00398E", "OrangeFF9500",
    //    2nd screen – lipstick pink
    "E69D95", "E07260", "C83773", "B8A89F",
    "665A5C", "C64247", "B4938C", "EAA598",
    "9B7983", "B897BB", "885D8D", "742E34",
    "E07260", "E69D95"
]


extension Color {
    static func appColor(_ id: Int) -> Color? {
        var name: String
        if id < 28 { name = AssetColorList[id] }
        else { name = "00000"}
        return Color.init(name, bundle: nil)
    }
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
    var pageIndex: Int
    
    var body: some View {
        VStack {
            Text(person.firstName + " " + person.lastName)
                .font(.system(size: fontsize))
                .foregroundColor(Color.white)
                .frame(width: width, height: height, alignment: .center)
                //.border(Color.gray, width: bordersize)
                .background(Color.appColor(person.id - 1 + pageIndex))
        }.cornerRadius(8)
    }
}
