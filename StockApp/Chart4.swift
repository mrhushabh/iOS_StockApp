import SwiftUI
import WebKit


struct Earnings: Codable {
    let period: String
    let actual: Double
    let estimate: Double
    let surprise: Double
}


struct WebfourView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}


struct ChartfourView: View {
    @State private var htmlContent: String = ""
    let symbol: String

    var body: some View {
        WebfourView(htmlContent: htmlContent)
            .onAppear {
                fetchData(for: symbol)
            }
    }

    private func fetchData(for symbol: String) {
        guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/Chart4?symbol=\(symbol)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned from API call")
                return
            }
            
            DispatchQueue.main.async {
                self.htmlContent = self.generateChartHTML(data: data)
            }
        }.resume()
    }

    private func generateChartHTML(data: Data) -> String {
        guard let earningsData = try? JSONDecoder().decode([Earnings].self, from: data) else {
            return "<p>Error decoding data</p>"
        }

        let categories = earningsData.map { "\"\($0.period), Surprise: \($0.surprise)\"" }.joined(separator: ", ")
        
        let actualValues = earningsData.map { $0.actual }
        let estimateValues = earningsData.map { $0.estimate }

        
        let actualValuesString = actualValues.map { String($0) }.joined(separator: ", ")
        let estimateValuesString = estimateValues.map { String($0) }.joined(separator: ", ")

        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
               <meta charset="UTF-8">
               <meta name="viewport" content="width=device-width, initial-scale=1.0">
               <script src="https://code.highcharts.com/highcharts.js"></script>
               <script src="https://code.highcharts.com/stock/highstock.js"></script>
               <script src="https://code.highcharts.com/stock/modules/data.js"></script>
               <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>
               <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
               <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
               <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>
        </head>
        <body>
            <div id="container" style="width: 100%; height: 80%;"></div>
            <script>
                document.addEventListener('DOMContentLoaded', function () {
                    Highcharts.chart('container', {
                        chart: { type: 'spline' },
                        title: { text: 'Historical EPS Surprises' },
                        xAxis: {
                            categories: [\(categories)],
                            labels:{
                                rotation: -45,
                                style:{textOverflow: 'none',
                                        fontsize: '45px'}
                            }
        
                        },
        
                        yAxis: { title: { text: 'Quarterly EPS' } },
                        series: [{
                            name: 'Actual',
                            data: [\(actualValuesString)]
                        }, {
                            name: 'Estimate',
                            data: [\(estimateValuesString)]
                        }]
                    });
                });
            </script>
        </body>
        </html>
        """
    }

}

struct ChartfourView_Previews: PreviewProvider {
    static var previews: some View {
        ChartfourView(symbol: "AAPL")
    }
}
