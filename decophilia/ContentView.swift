//
//  ContentView.swift
//  decophilia
//
//  Created by Diego Asua on 10/16/23.
//

import SwiftUI


struct Skyscraper: Identifiable, Hashable, Codable {
    var id: Int
    var name: String
    var location: String
    var imageName: String
}

extension UserDefaults {
    func setSkyscrapers(_ skyscrapers: [Skyscraper], forKey key: String) {
        if let encoded = try? JSONEncoder().encode(skyscrapers) {
            set(encoded, forKey: key)
        }
    }
    
    func skyscrapers(forKey key: String) -> [Skyscraper]? {
        if let data = data(forKey: key),
           let decoded = try? JSONDecoder().decode([Skyscraper].self, from: data) {
            return decoded
        }
        return nil
    }
}


let sampleSkyscrapers: [Skyscraper] = [
    Skyscraper(id: 0, name: "Empire State Building", location: "NYC", imageName: "empireState"),
    Skyscraper(id: 1, name: "Shanghai Tower", location: "Shanghai", imageName: "shanghaiTower"),
    Skyscraper(id: 2, name: "450 Sutter Street", location: "SF", imageName: "450ShutterStreet"),
    Skyscraper(id: 3, name: "One Wall Street", location: "NYC", imageName: "OneWallStreet"),
    Skyscraper(id: 4, name: "Chrysler Building", location: "NYC", imageName: "chryslerBuilding"),
    Skyscraper(id: 5, name: "Woolworth Building", location: "NYC", imageName: "woolworthBuilding"),
    Skyscraper(id: 6, name: "The Harrison", location: "SF", imageName: "theHarrison"),
    Skyscraper(id: 6, name: "Infinity Towers", location: "SF", imageName: "infinityTowers")
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
        if !likedSkyscrapers.contains(sampleSkyscrapers[currentIndex]) {
            likedSkyscrapers.append(sampleSkyscrapers[currentIndex])
            UserDefaults.standard.setSkyscrapers(likedSkyscrapers, forKey: "LikedSkyscrapers")
        }
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
    @Binding var likedSkyscrapers: [Skyscraper] // Change to @Binding
    @State private var selectedSkyscraper: Skyscraper?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Setting the light brown color for the whole background
                Color(red: 0.92, green: 0.87, blue: 0.80)
                    .edgesIgnoringSafeArea(.all) // This ensures it covers the full screen
                
                List {
                    ForEach(likedSkyscrapers, id: \.self) { skyscraper in
                        VStack(alignment: .leading) {
                            Image(skyscraper.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                            Text(skyscraper.name).font(.headline)
                            Text(skyscraper.location).font(.subheadline)
                        }
                        .background(
                            NavigationLink(
                                destination: ARImageView(imageName: skyscraper.imageName),
                                tag: skyscraper,
                                selection: $selectedSkyscraper,
                                label: { EmptyView() }
                            )
                        )
                        .onTapGesture {
                            self.selectedSkyscraper = skyscraper
                        }
                    }
                    .onDelete(perform: delete) // Add this for swipe-to-delete functionality
                }
                .listStyle(PlainListStyle()) // Removes default list style and separators
                .navigationBarItems(trailing: EditButton()) // Add this for an Edit button to toggle delete mode
            }
        }
    }
    
    // Add this function to handle deletion
    func delete(at offsets: IndexSet) {
        likedSkyscrapers.remove(atOffsets: offsets)
        UserDefaults.standard.setSkyscrapers(likedSkyscrapers, forKey: "LikedSkyscrapers")
    }
}



struct ContentView: View {
    @State private var showMatches = false
    @State private var likedSkyscrapers: [Skyscraper] = UserDefaults.standard.skyscrapers(forKey: "LikedSkyscrapers") ?? []
    
    var body: some View {
        ZStack {
            // Setting the light brown color for the whole background
            Color(red: 0.92, green: 0.87, blue: 0.80) // You can adjust these values to get the shade you desire
                .edgesIgnoringSafeArea(.all) // This ensures it covers behind the notch etc.
            
            VStack {
                if showMatches {
                    MatchesView(likedSkyscrapers: $likedSkyscrapers)
                } else {
                    SwipingView(likedSkyscrapers: $likedSkyscrapers)
                }
                
                Button(action: {
                    showMatches.toggle()
                }) {
                    Text(showMatches ? "Back to Swiping" : "Show Matches")
                        .font(.headline) // A placeholder font, consider using a custom hand-drawn font
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(Color.gray)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                                .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        )
                }.padding(.top, 20)
            }
        }
    }
}


#Preview {
    ContentView()
}
