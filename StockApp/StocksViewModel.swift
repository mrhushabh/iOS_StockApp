import Combine
import SwiftUI
struct Stock: Decodable {
    let stockName: String
    let symbol: String
    let price: Double
    let change: Double
    let percentChange: Double
}
class StocksViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var searchText = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .flatMap { searchText -> AnyPublisher<[Stock], Error> in
                guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/stocks?query=AAPL") else {
                    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
                }
                
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map(\.data)
                    .decode(type: [Stock].self, decoder: JSONDecoder())
                    .catch { _ in Empty(completeImmediately: true).eraseToAnyPublisher() } // Corrected
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main) // Switch to the main thread before updating the UI
            .catch { _ in Empty(completeImmediately: true).eraseToAnyPublisher() } // Corrected
            .sink(receiveValue: { [weak self] stocks in
                self?.stocks = stocks
            })
            .store(in: &cancellables)
    }
}
