//
//  ContentView.swift
//  TableSwiftUI
//
//  Created by Palacios, Litzy N on 3/31/25.
//

import SwiftUI
import MapKit

// Sample data
let data = [
    Item(name: "Lago de Ilopango", neighborhood: "Dolores Apulo", desc: "A breathtaking lake with deep blue waters, inviting visitors to swim, kayak, or embark on a scenic boat tour. You can also enjoy delicious bites from local snack and food stands, making it the perfect spot to relax and explore.", lat: 13.7000, long: -89.0833, imageName: "salv1", add:"Km. 16 Cantón Dolores, Carretera a Corinto, Ilopango, El Salvador"),
    Item(name: "National Palace", neighborhood: "San Salvador", desc: "A stunning architectural gem in the heart of the country's capital city. It was built in the early 20th century and is a historic landmark that showcases the country’s rich past.", lat: 13.6975, long: -89.1917, imageName: "salv2", add:"Avenida Cuscatlan, San Salvador, El Salvador"),
    Item(name: "Finca Rauda", neighborhood: "Alegria", desc: "A paradise full of adventures for nature lovers and thrill-seekers. They offer scenic trails, amazing viewpoints, RV riding, zip-lining, and camping. They also have a variety of delicious local cuisine.", lat: 13.50751, long: -88.48359, imageName: "salv3", add:"Cantón San Juan, Desvío a la Laguna de Alegría, Usulutan, El Salvador"),
    Item(name: "Cuevas de Moncagua", neighborhood: "Moncagua", desc: "This destination features crystal-clear thermal pools surrounded by ancient rock formations that create a cave. You can relax in the warm waters, rent chairs and tables, and enjoy snacks or fruits from the food stands.", lat: 13.5324, long: -88.2483, imageName: "salv4", add:"GQM2+2MQ, Moncagua, El Salvador"),
    Item(name: "Biblioteca Nacional", neighborhood: "San Salvador", desc: "Biblioteca Nacional de El Salvador (BINAES). A new modern library in the capital city. It has a vast collection of books, digital resources, and interactive spaces. BINAES offers a world of knowledge for all ages with engaging workshops and immersive exhibits.", lat: 13.6968, long: -89.1913, imageName: "salv5", add:"4 Calle Ote., San Salvador, El Salvador")
]

// Define the structure for the item
struct Item: Identifiable {
    let id = UUID()
    let name: String
    let neighborhood: String
    let desc: String
    let lat: Double
    let long: Double
    let imageName: String
    let add: String
}

struct ContentView: View {
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.50751, longitude:-88.48359), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 1.5))
    
    // New State for title animation
    @State private var opacity: Double = 0
    
    // State for the selected neighborhood filter and filtered data
    @State private var selectedNeighborhood: String = "All"
    @State private var filteredData = data
    
    // Get unique neighborhoods from the data
    let neighborhoods = ["All"] + Array(Set(data.map { $0.neighborhood })).sorted()

    var body: some View {
        NavigationView {
            VStack {
                
                Text("Explore El Salvador")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.4)) // Custom dark blue
                    .opacity(opacity) // Controlling the opacity for fade-in
                    .onAppear {
                        withAnimation(.easeIn(duration: 2).delay(0.5)) {
                            opacity = 1 // Fade in after a short delay
                        }
                    }
                
                // Neighborhood filter dropdown (Picker)
                Picker("Select Neighborhood", selection: $selectedNeighborhood) {
                    ForEach(neighborhoods, id: \.self) { neighborhood in
                        Text(neighborhood).tag(neighborhood)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // This makes it look like a dropdown
                .padding(.horizontal) // Reduced horizontal padding
                .frame(height: 30) // Reduced height for a more compact look
                .font(.subheadline) // Smaller font size
                .onChange(of: selectedNeighborhood) { newNeighborhood in
                    // Filter data when neighborhood changes
                    if newNeighborhood == "All" {
                        filteredData = data
                    } else {
                        filteredData = data.filter { $0.neighborhood == newNeighborhood }
                    }
                }
                
    
                
                // List for displaying filtered data
                List(filteredData, id: \.name) { item in
                    NavigationLink(destination: DetailView(item: item)) {
                        HStack {
                            Image(item.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(5)
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.neighborhood)
                                    .font(.subheadline)
                            } // end internal VStack
                        } // end HStack
                    } // end NavigationLink
                } // end List
                
                // Map to show locations of filtered items
                Map(coordinateRegion: $region, annotationItems: filteredData) { item in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long)) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                            .overlay(
                                Text(item.name)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .offset(y: 25)
                            )
                    }
                } // end Map
                .frame(height: 300)
                .padding(.bottom, -30)
                
            } // end VStack
            .listStyle(PlainListStyle())
        } // end NavigationView
    } // end body
}

struct DetailView: View {
    
    @State private var region: MKCoordinateRegion
         
    init(item: Item) {
        self.item = item
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    }
    
    let item: Item
                
    var body: some View {
        VStack {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200)
            Text("Neighborhood: \(item.neighborhood)")
                .font(.subheadline)
                .bold()
            Text("Description: \(item.desc)")
                .font(.subheadline)
                .padding(10)
            Text("Address: \(item.add)")
                .font(.subheadline)
                .padding(5)
                
            // Map for location details
            Map(coordinateRegion: $region, annotationItems: [item]) { item in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long)) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                        .overlay(
                            Text(item.name)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: true, vertical: false)
                                .offset(y: 25)
                        )
                }
            } // end Map
            .frame(height: 300)
            .padding(.bottom, -30)
        } // end VStack
        .navigationTitle(item.name)
        
        Spacer()
    } // end body
} // end DetailView 

#Preview {
    ContentView()
}
