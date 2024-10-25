import SwiftUI

struct ChartTabs: View {
    @Binding var selectedTab: ChartTab

        var body: some View {
            HStack {
                Spacer()

              
                Button(action: {
                    selectedTab = .hourly
                }) {
                    VStack {
                        Image(systemName: "chart.xyaxis.line")
                            .foregroundColor(selectedTab == .hourly ? .blue : .gray)
                        Text("Hourly")
                            .foregroundColor(selectedTab == .hourly ? .blue : .gray)
                    }
                }

                Spacer()

                Button(action: {
                    selectedTab = .historical
                }) {
                    VStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(selectedTab == .historical ? .blue : .gray)
                        Text("Historical")
                            .foregroundColor(selectedTab == .historical ? .blue : .gray)
                    }
                }

                Spacer()
            }
//            .padding()
            .background(Color.white) 
        }
    }


//struct ChartTabs_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartTabs()
//    }
//}
