
import SwiftUI

struct AddTripView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var place = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#FFF5EB"), Color(hex: "#FFE5CC")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trip Name")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                        TextField("e.g. Lake 12 Jan", text: $name)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(hex: "#FF8C42").opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: Color(hex: "#FF8C42").opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                            .foregroundColor(Color(hex: "#2C3E50"))
                            .accentColor(Color(hex: "#FF8C42"))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Place")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                        TextField("e.g. Crystal Lake", text: $place)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(hex: "#FF8C42").opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: Color(hex: "#FF8C42").opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                            .foregroundColor(Color(hex: "#2C3E50"))
                            .accentColor(Color(hex: "#FF8C42"))
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#2C3E50").opacity(0.7))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let trip = Trip(name: name, place: place, date: Date())
                        store.addTrip(trip)
                        dismiss()
                    }
                    .foregroundColor(name.isEmpty || place.isEmpty ? Color(hex: "#FF8C42").opacity(0.4) : Color(hex: "#FF8C42"))
                    .font(.system(size: 17, weight: .semibold))
                    .disabled(name.isEmpty || place.isEmpty)
                }
            }
        }
    }
}
