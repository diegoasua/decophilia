//
//  decophiliaApp.swift
//  decophilia
//
//  Created by Diego Asua on 10/16/23.
//

import SwiftUI


struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color(red: 0.92, green: 0.87, blue: 0.80)
                .edgesIgnoringSafeArea(.all)
            
            Image("loadingIcon") // Assuming the app icon asset is named "AppIcon"
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
        }
    }
}


@main
struct decophiliaApp: App {
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreen()
                    .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // Hide the launch screen after 2 seconds
                            showLaunchScreen = false
                        }
                    })
            } else {
                ContentView()
            }
        }
    }
}
