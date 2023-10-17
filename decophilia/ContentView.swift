//
//  ContentView.swift
//  decophilia
//
//  Created by Diego Asua on 10/16/23.
//

import SwiftUI

struct Skyscraper: Identifiable {
    var id: Int
    var name: String
    var location: String
    var imageName: String
}

let sampleSkyscrapers: [Skyscraper] = [
    Skyscraper(id: 0, name: "Empire State Building", location: "NYC", imageName: "empireState"),
    Skyscraper(id: 1, name: "Shanghai Tower", location: "Shanghai", imageName: "shanghaiTower"),
    // Add more skyscrapers as needed...
]

struct SwipingView: View {
    @State private var currentIndex: Int = 0
    @Binding var likedSkyscrapers: [Skyscraper]
    @State private var offset: CGSize = .zero

    var body: some View {
        VStack {
            Image(sampleSkyscrapers[currentIndex].imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 500)
                .clipShape(RoundedRectangle(cornerRadius: 15)) // Rounded corners
                .shadow(color: .gray, radius: 8, x: 0, y: 5)   // Shadow
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.offset = gesture.translation
                        }
                        .onEnded { gesture in
                            if self.offset.width < -100 {
                                self.dislike()
                            } else if self.offset.width > 100 {
                                self.like()
                            }
                            self.offset = .zero
                        }
                )
                .animation(.easeOut(duration: 0.2))
            
            Text(sampleSkyscrapers[currentIndex].name)
                .font(.title2)
                .fontWeight(.bold)
            Text(sampleSkyscrapers[currentIndex].location)
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundColor(.gray)
            
        }.padding()
    }
    
    func like() {
        likedSkyscrapers.append(sampleSkyscrapers[currentIndex])
        moveToNextSkyscraper()
    }
    
    func dislike() {
        moveToNextSkyscraper()
    }
    
    func moveToNextSkyscraper() {
        if currentIndex < sampleSkyscrapers.count - 1 {
            currentIndex += 1
        }
    }
}

struct MatchesView: View {
    var likedSkyscrapers: [Skyscraper]
    
    var body: some View {
        List(likedSkyscrapers) { skyscraper in
            VStack(alignment: .leading) {
                Image(skyscraper.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                Text(skyscraper.name).font(.headline)
                Text(skyscraper.location).font(.subheadline)
            }
        }
    }
}

struct ContentView: View {
    @State private var showMatches = false
    @State private var likedSkyscrapers: [Skyscraper] = []
    
    var body: some View {
        VStack {
            if showMatches {
                MatchesView(likedSkyscrapers: likedSkyscrapers)
            } else {
                SwipingView(likedSkyscrapers: $likedSkyscrapers)
            }
            
            Button(action: {
                showMatches.toggle()
            }) {
                Text(showMatches ? "Back to Swiping" : "Show Matches")
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: .gray, radius: 8, x: 0, y: 5)
            }.padding(.top, 20)
        }
    }
}



#Preview {
    ContentView()
}
