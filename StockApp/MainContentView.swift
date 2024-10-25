import SwiftUI


struct AutocompleteResponse: Decodable {
    let result: [String: AutocompleteItem]
}
struct CashBalance: Decodable{
    let Money : Double
}
struct PortfolioStock: Codable, Identifiable{
    var id: String { symbol }
    let symbol : String
    let stockName: String
    let quantity: Int
    let change: Double
    let Total: Double
    var mchange: Double?
    var mprice: Double?
    var mpercent: Double?
   
}
struct FavStock: Codable, Identifiable{
    var id: String { symbol }
    let symbol : String
    let stockName: String
    let price: Double
    let change: Double
    let percentchange: Double
   
}
struct StockDetails: Decodable {
    let c: Double  // Current price
    let h: Double  // High price of the day
    let l: Double  // Low price of the day
    let d: Double  // Price change
    let dp: Double // Percent change
}
//
//struct AutocompleteItem: Decodable, Identifiable {
//    let id = UUID()
//    let description: String
//    let displaySymbol: String
//    let symbol: String
//    let type: String
//}

struct MainContentView: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
    @State private var searchText = ""
    @State private var isSearchActive = false
    @State private var Portfolio: [PortfolioStock] = []
    @State private var Watchlist: [FavStock] = []
    @State private var autocompleteItems: [AutocompleteItem] = []
    @State private var cashBalance = 0.0
    @State private var editMode: EditMode = .inactive
    @State private var netWorth: Double = 25000
    @State private var isLoading = true
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }

    private func fetchCashBalance() {
       
        guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/Money") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                  
                    let decodedResponse = try JSONDecoder().decode(CashBalance.self, from: data)
                    DispatchQueue.main.async {
                       
                        self.cashBalance = Double(decodedResponse.Money)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.cashBalance = 0.0
                    }
                    print("Decoding error: \(error)")
                }
            } else if let error = error {
                print("Networking error: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func fetchAutocompleteSuggestions(for query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/stocks?query=\(encodedQuery)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
              
                let decodedDictionary = try JSONDecoder().decode([String: AutocompleteItem].self, from: data)
                DispatchQueue.main.async {
                 
                    self.autocompleteItems = Array(decodedDictionary.values)
                    print(self.autocompleteItems)
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }.resume()
    }


    var body: some View {
//        NavigationView {
//            
//            
//            List {
                //                if !isSearchActive {
                //                    Text("Stocks")
                //                        .font(.system(size: 36))
                //                        .frame(height: 50)
                //                        .bold()
//                //                        .listRowBackground(Color.clear)
//            if isLoading {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .scaleEffect(1.5)
//                    .onAppear {
//                        loadDataWithDelay()
//                    }
//            } else {
                //   
//    }
        
        NavigationView {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }else{
                //            .onAppear {
                ////                loadDataWithDelay()
                //            }
                //            } else {
                VStack{
                    
                    List {
                        ZStack(alignment: .leading) {
                            Color(.systemGray5)
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                                
                                TextField("Search", text: $searchText)
                                    .background(Color(.clear))
                                
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        withAnimation {
                                            self.isSearchActive = true
                                        }
                                    }
                                    .onChange(of: searchText) { oldValue, newValue in
                                    
                                        self.isSearchActive = true
                                        if isSearchActive && !newValue.isEmpty {
                                            fetchAutocompleteSuggestions(for: newValue)
                                        }
                                    }
                                
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        self.searchText = ""
                                        self.isSearchActive = false
                                        self.autocompleteItems = []
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.trailing, 8)
                                }
                                
                                if isSearchActive {
                                    Button("Cancel") {
                                        withAnimation {
                                            self.isSearchActive = false
                                            self.searchText = ""
                                            self.autocompleteItems = []
                                        }
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 8)
                                }
                            }
                        }
                        
                        .frame(height: 40)
                        .cornerRadius(8)
                        .listRowBackground(Color.clear)
                        if !autocompleteItems.isEmpty {
                            ForEach(autocompleteItems, id: \.symbol) { item in
                                NavigationLink(destination: StockDetailView(symbol: item.symbol, name: item.description)) {
                                    VStack(alignment: .leading){
                                        Text(item.symbol)
                                        Text(item.description)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        else if searchText.isEmpty{
                            Section {
                                Text(currentDate)
                                    .foregroundColor(.gray)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            .frame(height: 40)
                            
                            
                            Section (header: Text("PORTFOLIO").font(.headline)){
                                HStack {
                                    VStack {
                                        Text("Net Worth")
                                            .font(.system(size: 21))
                                            .padding([.trailing], 20)
                                            .background(Color.white)
                                        
                                        Text("$\(netWorth, specifier: "%.2f")")
                                            .font(.system(size: 23))
                                            .bold()
                                            .padding([.trailing], 20)
                                            .background(Color.white)
                                    }
                                    VStack {
                                        Text("Cash Balance")
                                            .font(.system(size: 21))
                                            .padding([.leading], 20)
                                            .background(Color.white)
                                        
                                        Text("$\(cashBalance, specifier: "%.2f")")
                                            .font(.system(size: 23))
                                            .bold()
                                            .padding([.leading], 20)
                                            .background(Color.white)
                                    }
                                }
                                ForEach(Portfolio) { stock in
                                    NavigationLink(destination: StockDetailView(symbol: stock.symbol, name: stock.stockName)) {
                                        HStack{
                                            VStack(alignment:.leading){
                                                Text("\(stock.symbol)")
                                                    .fontWeight(.bold)
                                                    .font(.title3)
                                                Text("\(stock.quantity) shares")
                                                    .foregroundColor(.gray)
                                                
                                            }
                                            Spacer()
                                            VStack{
                                                Text("\(stock.Total,specifier: "%.2f")")
                                                HStack {
                                                    Image(systemName: stock.mchange ?? 0 >= 0 ? "arrow.up.right" : "arrow.down.forward")
                                                        .foregroundColor(stock.mchange ?? 0 >= 0 ? .green : .red)
                                                    Text("\(stock.mchange ?? stock.change, specifier: "%.2f")" )
                                                        .foregroundColor(stock.mchange ?? 0 >= 0 ? .green : .red)
                                                    
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                .onDelete(perform: deleteStocks)
                                .onMove(perform: moveStocks)
                            }
                            
                            
                            Section(header: Text("FAVORITES").font(.headline)){
                                ForEach(Watchlist) { stock in
                                    NavigationLink(destination: StockDetailView(symbol: stock.symbol, name: stock.stockName)) {
                                        HStack{
                                            VStack(alignment:.leading){
                                                Text("\(stock.symbol)")
                                                    .fontWeight(.bold)
                                                    .font(.title3)
                                                Text("\(stock.stockName)")
                                                    .foregroundColor(.gray)
                                                
                                            }
                                            Spacer()
                                            VStack{
                                                Text("\(stock.price,specifier: "%.2f")")
                                                HStack {
                                                    Image(systemName: stock.change >= 0 ? "arrow.up.right" : "arrow.down.forward")
                                                        .foregroundColor(stock.change >= 0 ? .green : .red)
                                                    Text("\(stock.change, specifier: "%.2f")(\(stock.percentchange, specifier: "%.2f"))%" )
                                                        .foregroundColor(stock.change >= 0 ? .green : .red)
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                .onDelete(perform: deleteFav)
                                .onMove(perform: moveFav)
                            }
                            Link("Powered by Finnhub.io", destination: URL(string: "https://finnhub.io/")!)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    .navigationBarItems(trailing: EditButton())
                    .environment(\.editMode, $editMode)
                    //            .navigationBarTitleDisplayMode(isSearchActive ? .automatic : .large)
                    .navigationTitle(isSearchActive ? " ":"Stocks")
                    .navigationBarHidden(isSearchActive)
                 
                    
                }
                .onAppear{
                    fetchCashBalance()
                    fetchPortfolio()
                    fetchWatchlist()
                }
            }
        }
        .onAppear {
                        fetchCashBalance()
                        fetchPortfolio()
                        fetchWatchlist()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            updatePortfolioDetails()
                        isLoading = false
                    }
                    }
            }

    private func deleteStocks(at offsets: IndexSet) {
           Portfolio.remove(atOffsets: offsets)
       }

       private func moveStocks(from source: IndexSet, to destination: Int) {
           Portfolio.move(fromOffsets: source, toOffset: destination)
       }
    private func deleteFav(at offsets: IndexSet) {

        let symbolsToDelete = offsets.map { Watchlist[$0].symbol }

     
        Watchlist.remove(atOffsets: offsets)

      
        for symbol in symbolsToDelete {
            guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/removefav") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = ["symbol": symbol]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Error: Failed to delete the stock from favorites on the server.")
                    return
                }
                if let error = error {
                    print("Error removing favorite: \(error.localizedDescription)")
                } else {
                    print("Successfully removed favorite: \(symbol)")
                }
            }.resume()
        }
    }

       private func moveFav(from source: IndexSet, to destination: Int) {
           Watchlist.move(fromOffsets: source, toOffset: destination)
       }
    private func fetchWatchlist() {
           guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/watchlist") else {
               print("Invalid URL for stocks")
               return
           }
           URLSession.shared.dataTask(with: url) { data, _, error in
               guard let data = data, error == nil else { return }
               if let decodedwatchlist = try? JSONDecoder().decode([FavStock].self, from: data) {
                   DispatchQueue.main.async {
                       self.Watchlist = decodedwatchlist
                   }
               }
           }.resume()
       }

    private func fetchPortfolio() {
           guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/portfolio") else {
               print("Invalid URL for stocks")
               return
           }
           URLSession.shared.dataTask(with: url) { data, _, error in
               guard let data = data, error == nil else { return }
               if let decodedPortfolio = try? JSONDecoder().decode([PortfolioStock].self, from: data) {
                   DispatchQueue.main.async {
                       self.Portfolio = decodedPortfolio
                   }
               }
           }.resume()
//        updatePortfolioDetails()
       }
    private func updatePortfolioDetails() {
        print("hello")
        print(Portfolio)
        for stock in Portfolio {
            fetchStockDetails(for: stock)
            print(Portfolio)
        }
    }
    func fetchStockDetails(for stock: PortfolioStock) {
        guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/quote?symbol=\(stock.symbol)") else {
            print("Invalid URL for fetching stock details")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Failed to fetch stock details:", error?.localizedDescription ?? "Unknown error")
                return
            }
            print(Portfolio)
            do {
                let details = try JSONDecoder().decode(StockDetails.self, from: data)
                DispatchQueue.main.async {
                    if let index = self.Portfolio.firstIndex(where: { $0.symbol == stock.symbol }) {
                        self.Portfolio[index].mprice = details.c // Assuming 'c' is the  // Low price
                        self.Portfolio[index].mchange = details.d // Price change
                        self.Portfolio[index].mpercent = details.dp // Percentage price change
                        self.calculateNetWorth()
                    }
                }
            } catch {
                print("Error decoding stock details:", error)
            }
            print(Portfolio)
        }.resume()
    }
    private func calculateNetWorth() {
        var totalStockValue = 0.0
        for stock in Portfolio {
            if let currentPrice = stock.mprice {
                totalStockValue += currentPrice * Double(stock.quantity)
            }
        }
        

            self.netWorth = cashBalance + totalStockValue
//        } else {
//            print("Error parsing cash balance")
//        }
    }
    
    
}


struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

