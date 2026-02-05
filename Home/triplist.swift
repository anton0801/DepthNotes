
import SwiftUI

struct TripsListView: View {
    @EnvironmentObject var store: DataStore
    @State private var searchText = ""
    @State private var showAddTrip = false
    
    var filteredTrips: [Trip] {
        if searchText.isEmpty {
            return store.trips
        }
        return store.trips.filter { $0.place.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#FFF5EB"), Color(hex: "#FFE5CC")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "#FF8C42"))
                        .font(.system(size: 18))
                    TextField("Search places", text: $searchText)
                        .foregroundColor(Color(hex: "#2C3E50"))
                        .accentColor(Color(hex: "#FF8C42"))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#FF8C42").opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "#FF8C42").opacity(0.1), radius: 8, x: 0, y: 2)
                )
                .padding()
                
                if filteredTrips.isEmpty {
                    EmptyStateView(
                        icon: "mappin.circle.fill",
                        title: "No trips yet",
                        description: "Create your first trip"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredTrips) { trip in
                                NavigationLink(
                                    destination: TripDetailView(tripId: trip.id)
                                        .environmentObject(store)
                                ) {
                                    TripCard(trip: trip)
                                }
                                .buttonStyle(CardButtonStyle())
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            store.deleteTrip(trip)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Trips")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddTrip = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                            .shadow(color: Color(hex: "#FF8C42").opacity(0.4), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddTrip) {
            AddTripView()
                .environmentObject(store)
        }
    }
}
