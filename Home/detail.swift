
import SwiftUI

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    let gradient: [String]
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                Text(label)
                    .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
            }
            Spacer()
            Text(value)
                .foregroundColor(Color(hex: "#2C3E50"))
                .fontWeight(.semibold)
        }
        .font(.system(size: 16))
    }
}
