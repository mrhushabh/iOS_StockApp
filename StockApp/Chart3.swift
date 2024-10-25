import SwiftUI
import WebKit

struct WebthreeView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = true 
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

struct ChartthreeView: View {
    let symbol: String
    @State private var htmlContent: String = ""
    
    var body: some View {
        WebthreeView(htmlContent: htmlContent)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                fetchChartData(for: symbol)
            }
    }
    
    private func fetchChartData(for symbol: String) {
        guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/Chart2?symbol=\(symbol)") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned from API call")
                return
            }
            
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            
            DispatchQueue.main.async {
                self.htmlContent = self.generateChartHTML(jsonString: jsonString)
            }
        }
        
        task.resume()
    }
    
    private func generateChartHTML(jsonString: String) -> String {
        """
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
            <div id="container" style="width: 100%; height: 100%;"></div>
            <script>
                document.addEventListener('DOMContentLoaded', function () {
                    var data = \(jsonString);
                    Highcharts.chart('container', {
                        chart: {
                            type: 'column'
                        },
                        title: {
                            text: 'Recommendation Trends'
                        },
                        xAxis: {
                            categories: data.map(entry => entry.period.substr(0, 7))
                        },
                        yAxis: {
                            min: 0,
                            title: {
                                text: '#Analysis'
                            }
                        },
                        legend: {
                          reversed: true
                        },
                        plotOptions: {
                          column: {
                            stacking: 'normal',
                            dataLabels: {
                              enabled: true,
                              format: '{point.y}',
                              color: 'black', // Text color
                              style: {
                                textOutline: 'white'
                              }
                            }
                          }
                        },
                        series: [{
                            color: '#008000',
                            name: 'Strong Buy',
                            data: data.map(entry => entry.strongBuy)
                        }, {
                            color: '#04af70',
                            name: 'Buy',
                            data: data.map(entry => entry.buy)
                        }, {
                            color: '#a68004',
                            name: 'Hold',
                            data: data.map(entry => entry.hold)
                        }, {
                            color: 'red',
                            name: 'Sell',
                            data: data.map(entry => entry.sell)
                        }, {
                            color: '#800080',
                            name: 'Strong Sell',
                            data: data.map(entry => entry.strongSell)
                        }]
                    });
                });
            </script>
        </body>
        </html>
        """
    }
}

//struct ChartthreeView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartthreeView(symbol: "AAPL")
//    }
//}
