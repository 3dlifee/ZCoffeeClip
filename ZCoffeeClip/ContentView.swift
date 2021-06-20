//
//  ContentView.swift
//  ZCoffeeClip
//
//  Created by Mario Fernandes on 18/06/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        VStack(alignment: .center) {
            
            Image("logoZcoffee")
            
            Image("popular")
                .padding(.leading, -180.0)
            
            HStack {
                
                Image("brazilCoffee")
                Spacer()
                Image("mintCoffee")
                Spacer()
                Image("sumatraCoffee")
                
            }
            
            .padding(.all, 10.0)
            .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.width)
            
            Button(action: {
                
            }) {
                
                Image("more")
                
            }
            .padding(.leading, 250.0)
            
            Spacer()
            Image("bottom")
            
        }
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.width)
        .background((Color("backG")))
        
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
