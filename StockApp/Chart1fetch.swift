import Foundation

class ChartDataFetcher: ObservableObject {
    @Published var tvalues: [String] = []
    @Published var cvalues: [String] = []

    var symbol: String

        init(symbol: String) {
            self.symbol = symbol
        }
    func fetchData() {
        let urlString = "https://uscreactdeployment.wl.r.appspot.com/api/Chart1?symbol=\(self.symbol)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ChartDataResponse.self, from: data)
                DispatchQueue.main.async {
                    self.tvalues = decodedResponse.tValues.map { "\($0)" }
                    self.cvalues = decodedResponse.cValues.map { "\($0)" }
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
}

struct ChartDataResponse: Codable {
    let tValues: [Int]
    let cValues: [Double]
}
