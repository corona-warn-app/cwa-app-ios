//
//  AboutView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 12.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

//    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
//    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];

import SwiftUI
import Combine

struct AboutView: View {
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        
        VStack{
            SingleActionBackView( title: "Edit View",
                                  buttonText: NSLocalizedString("Back", comment: "Navigation bar Back button"),
                                  action:{
                                    self.navigation.unwind()
            })
            VStack{
                Text("Call by Color 36").font(Font.custom(globalDataModel.font, size: 26))
                Text("Version 1.0").font(Font.custom(globalDataModel.font, size: 18))
                Text("Build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)").font(Font.custom(globalDataModel.font, size: 18))
                
                Image("Icon120").resizable().frame(width: 120, height: 120).cornerRadius(20)
                    Spacer()
                        .fixedSize()
                        .frame(width: 150, height: 150)
                
                Spacer()
                Text("Copyright 2020 Andreas Vogel").multilineTextAlignment(.leading).customFont(name: globalDataModel.font, style: .body).padding(.horizontal)
                
                
            }
        }
        
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}



struct SingleActionBackView: View{
    var title: String
    var buttonText: String
    var action: ()->Void
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        ZStack{
            //            Rectangle().fill(Color.secondary).frame( height: 40 )
            Rectangle().fill(colorScheme == .light ? Color.white : Color.black).frame( height: 40 )
            HStack{
                Button( action: action){ Text(self.buttonText).padding(.leading, 15)
                }.foregroundColor(Color.accentColor)
                Spacer()
            }
        }
    }
}


@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
struct CustomFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory

    var name: String
    var style: UIFont.TextStyle
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        return content.font(Font.custom(
            name,
            size: UIFont.preferredFont(forTextStyle: style).pointSize)
            .weight(weight))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func customFont(
        name: String,
        style: UIFont.TextStyle,
        weight: Font.Weight = .regular) -> some View {
        return self.modifier(CustomFont(name: name, style: style, weight: weight))
    }
}


