//
//  ContentView.swift
//  ZCoffeeTarget
//
//  Created by Mario Fernandes on 18/06/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZCoffeeSwiftUIView()
        }
       
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
   
}

func handleUserActivity(_ userActivity: NSUserActivity) {

    guard
        let incomingURL = userActivity.webpageURL,
        let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
        let _ = components.queryItems
    else {
        return
    }
   
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
