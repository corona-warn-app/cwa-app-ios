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
                                               cellcolor:Color.init("OrangeFF9500", bundle: nil) )
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
                           cellcolor:Color.init("Darkblue00398E", bundle: nil) )
                }
            }
            .tabItem {
                VStack {
                    Image("second")
                    Text("2nd")
                }
            }
            .tag(1)
            //NavigationLink("Hallo", destination: KurzwahlView2())
            //.edgesIgnoringSafeArea(.bottom)
        }
    }
}


enum AssetsColor: String {
    case OrangeFF9500
    case Darkblue00398E
    case colorAccent
    case colorPrimary
    case darkBlue
    case yellow
    case blue
}

var AssetColorList: [String] = [
    "OrangeFF9500","Darkblue00398E", "Darkblue00398E",  "Darkblue00398E", "Darkblue00398E",
    "Darkblue00398E", "Darkblue00398E", "Darkblue00398E", "Darkblue00398E", "Darkblue00398E",
     "Darkblue00398E", "Darkblue00398E"
]

extension Color {
    static func appColor(_ name: AssetsColor) -> Color? {
        return Color.init(name.rawValue, bundle: nil)
    }
}

extension Color {
    static func appColor(_ id: Int) -> Color? {
        let name: String = AssetColorList[id]
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
    var cellcolor: Color
    
    var body: some View {
        VStack {
            Text(person.firstName + " " + person.lastName)
                .font(.system(size: fontsize))
                .foregroundColor(Color.white)
                .frame(width: width, height: height, alignment: .center)
                //.border(Color.gray, width: bordersize)
                .background(Color.appColor(person.id - 1))
        }.cornerRadius(8)
    }
}
