import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlString: String
    let onLoad: ((WKWebView) -> Void)? 

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        onLoad?(webView)
    }
}

struct ChartView: View {
    var symbol: String
    var pricecol: Double
    
    var chartColor  = ""
//    let chartColor = pricecol ?? 0 >= 0 ? "green" : "red"
    @ObservedObject var dataFetcher: ChartDataFetcher

    init(symbol: String, pricecol: Double) {
        self.symbol = symbol
        self.pricecol = pricecol
        self.dataFetcher = ChartDataFetcher(symbol: symbol)
        
        self.chartColor = pricecol >= 0 ? "green" : "red"
        
    }

    var body: some View {
        
        WebView(htmlString: htmlContent, onLoad: { webView in
            let tValuesJS = "[\(self.dataFetcher.tvalues.map { String($0) }.joined(separator: ","))]"
            let cValuesJS = "[\(self.dataFetcher.cvalues.map { String($0) }.joined(separator: ","))]"
            let jsCode = "loadChart(\(tValuesJS), \(cValuesJS));"
            webView.evaluateJavaScript(jsCode, completionHandler: nil)
        })
        .frame(height: 400)
        .onAppear {
            self.dataFetcher.fetchData()
        }
    }
//    let chartColor = pricecol ?? 0 >= 0 ? "green" : "red"
    var htmlContent: String {
        
        """
        <!DOCTYPE html>
        <html>
        <head>
          <title>Highcharts Chart</title>
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
          <div id="chart-container" style="width: 100%; height: 400px;"></div>
          
          <script>
            function loadChart(tValues, cValues) {
              var categories = tValues.map(timestamp => {
                var date = new Date(timestamp);
                var hours = date.getHours();
                var minutes = (date.getMinutes() < 15 ? '0' : '') + date.getMinutes();
                return hours + ':' + minutes;
              });

              Highcharts.chart('chart-container', {
                chart: {
                  type: 'line'
                },
                title: {
                  text: '\(symbol)Hourly Price Variation'
                },
                navigator: {
                        enabled: false
                },
                scrollbar: {
                    enabled: true
                },
                xAxis: {
                  categories: categories
                },
                yAxis: [{
         
                  label: {
                  align: 'right',
                  x: -3
                    },
                 opposite: true,
        
                }],
                series: [{
                  name: 'Price Data',
                  data: cValues,
                  marker: {
                    enabled: false
                  },
                 color:'\(chartColor)'
                }]
              });
            }
          </script>
        </body>
        </html>
        """
    }
}

//
//struct ChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartView(symbol: "AAPL")
//    }
//}
