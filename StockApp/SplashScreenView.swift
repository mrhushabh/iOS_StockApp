import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct SplashScreenView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            Color(hex: 0xf2f5fa).edgesIgnoringSafeArea(.all)
            VStack {
                Image("app icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.isActive = false 
                }
            }
        }
    }
}
