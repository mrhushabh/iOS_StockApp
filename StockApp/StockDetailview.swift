import SwiftUI

struct StockData {
    let profile: CompanyProfile
    let quote: Quote
    let sentiment: Sentiment
    let shares: Int
    let total: Double
    let change: Double
    let marketv: Double
    let average: Double
    let peers: [String]
    let money: Money
}
struct Money: Decodable {
    let Money: Double


}
struct CompanyProfile: Decodable {
    let name: String
    let ipo: String
    let finnhubIndustry: String
    let weburl: URL
    let logo: URL

}
struct FavoriteStock: Decodable {
    let stockName: String
    let symbol: String
    let price: Double
    let change: Double
    let percentChange: Double
}
struct Quote: Decodable {
    let c: Double // Current price
    let d: Double //change
    let dp: Double //percent cahnge
    let h: Double // High price of the day
    let l: Double // Low price of the day
    let o: Double // Open price of the day
    let pc: Double // Previous close price
}
struct Shares: Decodable {
    let quantity: Int
    let Total: Double
    let change: Double
    let MarketV: Double
    let Average: Double
  
}
struct Sentiment: Decodable {
    let TC: Double
    let TM: Double
    let TPM: Double
    let TPC: Double
    let TNM: Double
    let TNC : Double

}

enum ChartTab: String, CaseIterable, Identifiable {
    case hourly
    case historical

    var id: String { self.rawValue }

    var icon: Image {
        switch self {
        case .hourly:
            return Image(systemName: "chart.xyaxis.line")
        case .historical:
            return Image(systemName: "clock")
        }
    }
}
struct NewsItem: Codable, Identifiable {
    let id: Int
    let headline: String
    let image: String
    let source: String
    let summary: String
    let datetime: Int
    let url: URL
}


class NewsViewModel: ObservableObject {
    @Published var newsItems: [NewsItem] = []

    func fetchNews(forSymbol symbol: String) {
        let urlString = "https://uscreactdeployment.wl.r.appspot.com/api/News?symbol=\(symbol)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([NewsItem].self, from: data)
                    DispatchQueue.main.async {
  
                        self.newsItems = decodedResponse.filter { item in
                            guard let imageUrl = URL(string: item.image), imageUrl.scheme != nil, imageUrl.host != nil else {
                                return false
                            }
                            return true
                        }.prefix(20).map { $0 } // Take only the first 20 valid items
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}
struct NewsDetailView: View {
    let newsItem: NewsItem
    @Environment(\.presentationMode) var presentationMode 

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()  // Dismiss the modal
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.title)
                            .opacity(0.8)
                    }
                }
                .padding(.trailing, 20)
                .padding(.top, 10)

                Text(newsItem.source)
                    .font(.title)
                    .fontWeight(.bold)

                Text("\(formatDate(newsItem.datetime))")  
                    .font(.subheadline)
                    .padding(.bottom, 2)

                Divider()

                Text(newsItem.headline)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(newsItem.summary)
                    .padding(.top,10)
                
                HStack {
                    Text("For more details click ")
                        .foregroundColor(.gray)
                    Link("here", destination:(newsItem.url))
                }
                .padding(.bottom, 10)
                
                HStack{
                    Link(destination: URL(string: "https://twitter.com/intent/tweet?text=\(newsItem.headline)&url=\(newsItem.url)")!) {
                        Image("twitter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }
                    Link(destination: URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(newsItem.url)")!) {
                        Image("facebook")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                    }
                }
            }
            .frame(width: 350)
            .padding([.top, .bottom], 50)
        }
        .padding(.horizontal)
    }
    
    func formatDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy" // Example format: "April 09, 2024"
        return dateFormatter.string(from: date)
    }
}

struct TradeView: View {
    @Binding var isPresented: Bool
    @Binding var showCongrats: Bool
    var symbol: String
    var price: Double
    var stockName: String
    var change: Double
    @Binding var quantity: Int
    @Binding var text: String
    var money: Double
    var sharesavailable: Int
    let performfetch: () -> Void
    @State private var showError1 = false
    @State private var showError2 = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                HStack{
                    TextField("0", value: $quantity, format: .number)
                        .keyboardType(.numberPad)
                        .font(.system(size: 150))
                        .frame(height: 500)
                        .padding(.leading,10)
         
                    VStack{
                        Text("Share")
                            .padding([.bottom,.top],30)
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                        
                        Text("x \(price,specifier: "%.2f") = \(Double((quantity))*(price),specifier: "%.2f")")
                    };
                }
                Spacer()
                
//                if showError1 {
//                    Text("Please enter a valid amount")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                        .padding(15)
//                        .padding([.trailing,.leading],55)
//                        .background(Color.black)
//                        .cornerRadius(30)
//                        .frame(minWidth: 200)
//                }
//                if showError2 {
//                    Text("Not enough to sell")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                        .padding(15)
//                        .padding([.trailing,.leading],55)
//                        .background(Color.black)
//                        .cornerRadius(30)
//                        .frame(minWidth: 200)
//                }
                Text("$\(String(format: "%.2f",money)) available to buy \(symbol)")
                    .padding()
                    .padding(.leading,50)
                    .foregroundColor(.gray)
                HStack{
                    Button(action: {

                        if quantity <= 0 {
                            showError1 = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                              
                                showError1 = false
                            }
                        } else {
                            
                            buyStock(stockName: stockName, quantity: quantity, price: price, change: change, symbol: symbol)
                            performfetch()
                            self.isPresented = false
                            showCongrats = true
                            text = "bought"
                        }
                    }) {
                        
                        Text("Buy")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(15)
                            .padding([.trailing,.leading],55)
                            .background(Color.green)
                            .cornerRadius(30)
                            .frame(minWidth: 200)
                    }

                    Button(action: {
                        if sharesavailable<quantity{
                            showError2 = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                              
                                showError2 = false
                            }
                        }
                       else if quantity > 0 {
                            sellStock(stockName: stockName, quantity: quantity, price: price)
                           performfetch()
                            self.isPresented = false
                            showCongrats = true
                            text = "sold"
                        }else{
                            showError1 = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                              
                                showError1 = false
                            }
                        }
                  
                    }) {
                        Text("Sell")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(15)
                            .padding([.trailing,.leading],55)
                           
                            .background(Color.green)
                            .cornerRadius(30)
                            .frame(minWidth: 200)
                    }
                    
       
                }
            }
            .overlay(
            
                VStack {
                    Spacer()
                    if showError1 {

                        Text("Please enter a valid amount")
                            .padding([.trailing,.leading],80)
                            .padding([.top,.bottom],30)
                            .background(Color.gray.opacity(1.0))
                            .cornerRadius(20)
                            .foregroundColor(Color.white)

                            .animation(.easeInOut, value: showError1)
                    }
                    
                                        if showError2 {
                 
                                            Text("Not enough to sell")
                                                .padding([.trailing,.leading],80)
                                                .padding([.top,.bottom],30)
                                                .background(Color.gray.opacity(1.0))
                                                .cornerRadius(20)
                                                .foregroundColor(Color.white)
             
                                                .animation(.easeInOut, value: showError2)
                                        }
                }
                .edgesIgnoringSafeArea(.bottom)
                )


            .navigationBarTitle(Text("Trade \(symbol) shares"), displayMode: .inline)
            .navigationBarItems(trailing: Button("x") {
                self.isPresented = false
            })

        }
        .onDisappear{
            performfetch()
//            quantity = 0
        }
    }
    
    func buyStock(stockName: String, quantity: Int, price: Double, change: Double, symbol: String) {
        let buyEndpoint = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/buy")!
        var request = URLRequest(url: buyEndpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let buyData = ["quantity": quantity, "price": price, "stockName": stockName, "change": change, "symbol": symbol] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: buyData, options: [])
        } catch let error {
            print("Failed to serialize JSON:", error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred during network request:", error)
                return
            }
           
        }.resume()
    }
    func sellStock(stockName: String, quantity: Int, price: Double) {
            let endpoint = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/sell")!
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let postData = ["quantity": quantity, "price": price, "stockName": stockName] as [String : Any]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: postData, options: [])
            } catch {
                print("Failed to serialize JSON:", error)
            }
            
            URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    print("Error occurred during network request:", error)
                }
            }.resume()
        }
    

}

struct CongratsView: View {
    @Binding var showCongrats: Bool
    @Binding var quantity: Int
    var Symbol: String
    @Binding var text: String
    let performfetch: () -> Void
//    showCongrats = true
    var body: some View {
        VStack {
            Spacer()
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("You have successfully \(text) \(quantity) shares of \(Symbol).")
                .foregroundColor(.white)
                .padding()
            Spacer()
            Button(action: {
                showCongrats = false
                quantity = 0
                performfetch()
              
            }){
                Text("Done")
            }
            .fontWeight(.semibold)
            .foregroundColor(.green)
            .padding(15)
            .padding([.trailing,.leading],95)
            .background(Color.white)
            .cornerRadius(30)
            .frame(minWidth: 200, minHeight: 50)
            
        }
       
 
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
    }

}




struct StockDetailView: View {
    let symbol: String
    let name: String
    var hourly  = Image(systemName: "chart.xyaxis.line")
    @State private var stockData: StockData?
    @State private var selectedTab: ChartTab = .hourly
    @ObservedObject var newsViewModel = NewsViewModel()
    @State private var selectedItem: NewsItem?
    @State private var showingTradeView = false
    @State private var inWatchlist = false
    @State private var CongratsView = false
    @State var quantity: Int = 0
    @State var tradetext: String = " "
    @State private var showOverlay = false
    @State private var isLoading = true
    var body: some View {
            GeometryReader { geometry in
//                if let stockData = stockData {
                ScrollView {
                    if let stockData = stockData {

                        VStack{

                            VStack(alignment: .leading, spacing: 8) {
                                HStack{
                                    Text(stockData.profile.name)
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    AsyncImage(url:  stockData.profile.logo){ image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                }
                                    HStack(spacing: 4) {
                                        Text("$\(stockData.quote.c, specifier: "%.2f")")
                                            .font(.title)
                                            .fontWeight(.semibold)
                                        
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Image(systemName: stockData.quote.d >= 0 ? "arrow.up.right" : "arrow.down.forward")
                                                    .foregroundColor(stockData.quote.d >= 0 ? .green : .red)
                                                Text("\(stockData.quote.d, specifier: "%.2f") (\(stockData.quote.dp, specifier: "%.2f")%)")
                                                    .foregroundColor(stockData.quote.d >= 0 ? .green : .red)
                                            }
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        }
                                    }

                                    Group {
                                        if selectedTab == .hourly {
                                  
                                            ChartView(symbol: symbol, pricecol: stockData.quote.d)
                                        
                                        } else {

                                            Charttwo(symbol: symbol)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    ChartTabs(selectedTab: $selectedTab)
                       
                                    Text("Portfolio")
                                        .font(.title2)
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            // Conditional display based on the number of shares
                                            if stockData.shares > 0 {
                                 
                                                
                                                HStack{
                                                    Text("Shares Owned:")
                                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                    Text(String(stockData.shares))
                                                }
                                                Spacer()
                                                HStack{
                                                    Text("Avg. Cost/Share:")
                                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                    Text("$ \(String(format: "%.2f",stockData.average))")
                                                }
                                                Spacer()
                                                HStack{
                                                    Text("Total Cost:")
                                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                    Text("$ \(String(format: "%.2f",stockData.total))")
                                                }
                                                Spacer()
                                                HStack{
                                                    Text("Change:")
                                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                    Text("$ \(String(format: "%.2f",stockData.change))")
                                                        .foregroundColor(stockData.quote.d >= 0 ? .green : .red)
                                                }
                                                Spacer()
                                                HStack{
                                                    Text("Market value:")
                                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                    Text("$ \(String(format: "%.2f",stockData.marketv))")
                                                }
                                                Spacer()
                                                
                                            } else {
                                                Text("You have 0 shares of \(symbol)")
                                                    .font(.subheadline)  
                                                Text("Start trading!")
                                                    .font(.subheadline)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            showingTradeView = true
                                          
                                        }) {
                                            Text("Trade")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(15)
                                                .padding([.trailing,.leading],40)
                                                .background(Color.green)
                                                .cornerRadius(30)
                                                .frame(minWidth: 150)
                                        }
                                        .sheet(isPresented: $showingTradeView) {
                                            TradeView(isPresented: $showingTradeView,showCongrats: $CongratsView, symbol: symbol, price: stockData.quote.c, stockName: name, change: stockData.quote.d, quantity: $quantity, text: $tradetext, money: stockData.money.Money, sharesavailable: stockData.shares,
                                                      performfetch:  fetchData)
                                            
                                        }
                                        .sheet(isPresented: $CongratsView) {
                                            
                                      
                                        }
                                    }
                                    
                                    Spacer()
                                    Text("Stats")
                                        .font(.title2)
                                    HStack {
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("High Price: $\(String(format: "%.2f", stockData.quote.h))")
                                            Spacer()
                                            Text("Low Price: $\(String(format: "%.2f", stockData.quote.l))")
                                        }.padding(.trailing,30)
                                        
                                        
                                        
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Open Price: $\(String(format: "%.2f", stockData.quote.c))")
                                            Spacer()
                                            Text("Prev. Close: $\(String(format: "%.2f", stockData.quote.pc))")
                                        }
                                    }
                                    .font(.subheadline)
                                    Spacer()
                                    Text("About")
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("IPO Start Date:")
                                                .fontWeight(.bold)
                                            Spacer()
                                            Text(stockData.profile.ipo)
                                        }
                                        
                                        HStack {
                                            Text("Industry:")
                                                .fontWeight(.bold)
                                            Spacer()
                                            Text(stockData.profile.finnhubIndustry)
                                        }
                                        
                                        HStack {
                                            Text("Webpage:")
                                                .fontWeight(.bold)
                                            Spacer()
                                         
                                            Link(stockData.profile.weburl.absoluteString, destination: stockData.profile.weburl)
                                        }
                                        
                                        HStack {
                                            Text("Company Peers:")
                                                .fontWeight(.bold)
                                            Spacer()
                                    
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                LazyHStack {
                                                    ForEach(stockData.peers.filter { !$0.contains(".") }, id: \.self) { peer in
                                                        NavigationLink(destination: StockDetailView(symbol: peer, name: "AAPL")) {
                                                            Text(peer)
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                           
                                        }
                                    }
                                   
                                    .font(.subheadline)
                                    Spacer()
                                    Text("Insights")
                                        .font(.title2)
                                    
                                    VStack {
                                        Text("Insider Sentiments")
                                            .font(.title2)
                                     
                                            .padding(.vertical)
                                        
                                  
                                        HStack {
                                            Text("Apple Inc").bold()
                                            Spacer()
                                            Text("MSPR").bold()
                                            Spacer()
                                            Text("Change").bold()
                                        }
                                        .padding(.horizontal)
                                        Divider()
                                        
                                  
                                        HStack {
                                            Text("Total")
                                            Spacer()
                                            Text("\(String(format: "%.2f", stockData.sentiment.TM))")
                                            Spacer()
                                            Text("\(String(format: "%.2f", stockData.sentiment.TC))")
                                            
                                        }
                                        .padding(.horizontal)
                                        Divider()
                                        
                                       
                                        HStack {
                                            Text("Positive")
                                            Spacer()
                                            Text("\(String(format: "%.2f", stockData.sentiment.TPM))")
                                            Spacer()
                                            Text("\(String(format: "%.2f", stockData.sentiment.TPC))")
                                            
                                            
                                        }
                                        .padding(.horizontal)
                                        Divider()
                                        
                                     
                                        HStack {
                                            Text("Negative")
                                            Spacer()
                                            Text("\(String(format: "%.2f", stockData.sentiment.TNM))")
                                            Spacer()
                                            Text("\(String(format: "%.2f", stockData.sentiment.TNC))")
                                            
                                        }
                                        .padding(.horizontal)
                                    }
                                    Spacer()
                                    ChartthreeView(symbol: symbol)
                                        .frame(height: 400)
                                        .frame(width: 380)
                                    ChartfourView(symbol: symbol)
                                        .frame(height: 400)
                                        .frame(width: 380)
                                    
                                    Spacer()
                                    
                                    Text("News")
                                        .font(.title2)
                                    Spacer()
                                    ForEach(Array(newsViewModel.newsItems.enumerated()), id: \.element.id) { (index, item) in
                                        if index == 0 {
                                            VStack(alignment: .leading) {
                                                AsyncImage(url: URL(string: item.image)) { image in
                                                    image.resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Color.gray.opacity(0.3)
                                                }
                                                //                                                 .aspectRatio(contentMode: .fit)
                                                .frame(width: 360, height: 250)
                                                .cornerRadius(10)
                                                
                                                HStack{
                                                    Text(item.source)
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                    Text(timeAgoDisplay(item.datetime))
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                                Text(item.headline)
                                                    .font(.headline)
                                                
                                                Spacer()
                                                Divider()
                                                Spacer()
                                            }
                                        } else {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack{
                                                        Text(item.source)
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                        Text(timeAgoDisplay(item.datetime))
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                    }
                                                    Text(item.headline)
                                                        .font(.headline)
                                                    
                                                    Spacer()
                                                    
                                                }
                                                .frame(width:240)
                                          
                                                AsyncImage(url: URL(string: item.image)) { image in
                                                    image.resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                    
                                                } placeholder: {
                                                    Color.gray.opacity(0.3)
                                                }
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 110)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                
                                                Spacer()
                                            }
                                            .frame(width: 360,height: 130)
                                            .onTapGesture {
                                                selectedItem = item
                                            }}
                                    }
   
                                
                            }
                            
                            .padding()
                            .frame(width: geometry.size.width, alignment: .topLeading)
                            
                        }
                        
                        .navigationBarTitle(symbol)
                        .sheet(item: $selectedItem) { item in
                            NewsDetailView(newsItem: item)
                        }
                        .onAppear{
                            fetchData()
                        }


                } else {
                    Spacer()
                    VStack{
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Fetching data")
                    }
                    .padding([.leading,.bottom,.top],150)
                    .padding(.top,170)
                }

                    }


            }

            .onAppear {
                fetchData()
                newsViewModel.fetchNews(forSymbol: symbol)
                checkIfInWatchlist(stockName: name)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    isLoading = false
                }
            }
            .overlay(
                
                VStack {
                    Spacer()
                    if showOverlay {
                        Text("Adding \(symbol) to Favorites")
                            .padding([.trailing,.leading],80)
                            .padding([.top,.bottom],30)
                            .background(Color.gray.opacity(0.9))
                            .cornerRadius(20)
                            .foregroundColor(Color.white)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: showOverlay)
                    }
                }
                    .edgesIgnoringSafeArea(.bottom)
            )

            .navigationBarItems(trailing: Button(action:{
                inWatchlist = true
                showOverlay = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                  
                    showOverlay = false
                }
                addStockToFavorites(stockName:name, symbol:symbol, change: stockData?.quote.d ?? 0.00, price:stockData?.quote.c ?? 0.00, percentchange: stockData?.quote.dp ?? 0.00)})
                                {
                Image(systemName: inWatchlist ? "plus.circle.fill" : "plus.circle")
                                       .imageScale(.large)
                                                }
            )

    }
    
    func timeAgoDisplay(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year) year(s) ago"
        } else if let month = components.month, month > 0 {
            return "\(month) month(s) ago"
        } else if let day = components.day, day > 0 {
            return "\(day) day(s) ago"
        } else if let hour = components.hour, hour > 0 {
          
            let minutePart = (components.minute ?? 0) > 0 ? ", \(components.minute!) min" : ""
            return "\(hour) hr \(minutePart)"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) min ago"
        } else {
            return "Just now"
        }
    }

    func addStockToFavorites(stockName: String, symbol: String, change: Double, price: Double, percentchange: Double) {
            let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/addfav")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let postData = ["stockName": stockName, "symbol": symbol, "price": price, "change": change, "percentchange": percentchange] as [String : Any]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: postData, options: [])
            } catch let error {
                print("Failed to serialize data:", error)
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error occurred during network request:", error)
                } else if let data = data {
                    if let response = try? JSONDecoder().decode(FavoriteStock.self, from: data) {
                        print("Favorite added: \(response)")
                    }
                }
            }.resume()
        }
        
    func checkIfInWatchlist(stockName: String) {
        let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/star")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let postData = ["stockName": stockName]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postData, options: [])
        } catch {
            print("Failed to serialize data:", error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred during network request:", error)
                return
            }
            guard let data = data else { return }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool],
                   let starState = jsonResponse["starstate"] {
                    DispatchQueue.main.async {
                        self.inWatchlist = starState
                    }
                }
            } catch {
                print("Error decoding JSON:", error)
            }
        }.resume()
    }


    func fetchData() {
        let dispatchGroup = DispatchGroup()
        
        var profile: CompanyProfile?
        var quote: Quote?
        var sentiment: Sentiment?
        var shares = 0
        var total = 0.0
        var change = 0.0
        var marketv = 0.0
        var average = 0.0
        var peers: [String] = []
        var money: Money?
        // Fetch company profile
        dispatchGroup.enter()
        if let profileURL = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/company?symbol=\(symbol)") {
            URLSession.shared.dataTask(with: profileURL) { data, _, _ in
                if let data = data {
                    profile = try? JSONDecoder().decode(CompanyProfile.self, from: data)
                }
                dispatchGroup.leave()
            }.resume()
        } else {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        if let peersURL = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/peers?symbol=\(symbol)") {
            URLSession.shared.dataTask(with: peersURL) { data, _, _ in
                if let data = data {
                    do {
                        peers = try JSONDecoder().decode([String].self, from: data)
                    } catch {
                        print("Error decoding peers data:", error)
                    }
                }
                dispatchGroup.leave()
            }.resume()
        } else {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
           if let sharesURL = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/portfoliostock?symbol=\(symbol)") {
               URLSession.shared.dataTask(with: sharesURL) { data, _, error in
                   if let data = data {
             
                       if let trades = try? JSONDecoder().decode([Shares].self, from: data), !trades.isEmpty {
                           shares = trades.map { $0.quantity }.reduce(0, +) 
                           total = trades.map { $0.Total }.reduce(0, +)
                           change = trades.map { $0.change }.reduce(0, +)
                           marketv = trades.map { $0.MarketV}.reduce(0, +)
                           average = trades.map { $0.Average }.reduce(0, +)
                       }
                   }
                   dispatchGroup.leave()
               }.resume()
           } else {
               dispatchGroup.leave()
           }


        // Fetch quote data
        dispatchGroup.enter()
        if let quoteURL = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/quote?symbol=\(symbol)") {
            URLSession.shared.dataTask(with: quoteURL) { data, _, _ in
                if let data = data {
                    quote = try? JSONDecoder().decode(Quote.self, from: data)
                }
                dispatchGroup.leave()
            }.resume()
        } else {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        if let sentimentURL = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/Sentiments?symbol=\(symbol)") {
            URLSession.shared.dataTask(with: sentimentURL) { data, _, _ in
                if let data = data {
                    sentiment = try? JSONDecoder().decode(Sentiment.self, from: data)
                }
                dispatchGroup.leave()
            }.resume()
        } else {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        if let MoneyURL = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/Money?symbol=\(symbol)") {
            URLSession.shared.dataTask(with: MoneyURL) { data, _, _ in
                if let data = data {
                    money = try? JSONDecoder().decode(Money.self, from: data)
                }
                dispatchGroup.leave()
            }.resume()
        } else {
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            if let profile = profile, let quote = quote, let sentiment = sentiment, let money = money {
                self.stockData = StockData(profile: profile, quote: quote, sentiment: sentiment, shares: shares, total: total, change: change, marketv: marketv, average: average, peers: peers, money: money)
            } else {
                print("Failed to fetch all data")
            }
        }    }
    
    
    
    
    
    
    
    
    
}
struct StockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            StockDetailView(symbol: "AAPL", name: "Apple Inc")
        }
    }
}
