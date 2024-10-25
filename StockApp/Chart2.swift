import SwiftUI
import WebKit

struct ChartWebView: UIViewRepresentable {
    var symbol: String
    @Binding var htmlContent: String  // Use @Binding to get updates from parent view

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ChartWebView

        init(_ parent: ChartWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            fetchDataAndUpdateChart()
        }

        func fetchDataAndUpdateChart() {
            guard let url = URL(string: "https://uscreactdeployment.wl.r.appspot.com/api/historical_data?symbol=\(parent.symbol)") else {
                print("Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                if let chartData = try? JSONDecoder().decode([ChartData].self, from: data) {
                    DispatchQueue.main.async {
                        self.parent.htmlContent = self.generateHTMLContent(chartData: chartData)
//                    print(chartData)
                    }
                } else {
                    print("Failed to decode data")
                }
            }.resume()
        }

        func generateHTMLContent(chartData: [ChartData]) -> String {
            let ohlcDataJSON = chartData.map { data in
                return "[\(data.timestamp), \(data.open), \(data.high), \(data.low), \(data.close)]"
            }.joined(separator: ", ")
            let volumeDataJSON = chartData.map { data in
                return "[\(data.timestamp),\(data.volume)]"
            }.joined(separator: ", ")
            print("od:",ohlcDataJSON)
            print("vol",volumeDataJSON)
            let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Historical Stock Market Data</title>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <script src="https://code.highcharts.com/stock/highstock.js"></script>
                <script src="https://code.highcharts.com/stock/modules/data.js"></script>
                <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>
                <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
                <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>

            </head>
            <body>
            <div id="container" style="height: 150%; min-width: 310px"></div>
            <script>
            function createChart() {
             const ohlc = [\(ohlcDataJSON)];
                const volume = [\(volumeDataJSON)];
                const groupingUnits = [
                        ['week',[1]],
                        ['month', [1, 2, 3, 4, 6]]
                ];
                const volumeSeries = {
                    type: 'column',
                    name: 'Volume',
                    data: volume,
                    yAxis: 1
                };
                const ohlcSeries = {
                    type: 'candlestick',
                    name: 'OHLC',
                    data: ohlc
                };

                Highcharts.stockChart('container', {
                    rangeSelector: {
                            selected: 2
                                },
                    yAxis: [{
                            startOnTick: false,
                            endOnTick: false,
                            labels: {
                                align: 'right',
                                x: -3
                            },
                            title: {
                                text: 'OHLC'
                            },
                            height: '60%',
                            lineWidth: 2,
                            resize: {
                                enabled: true
                            }
                            },  {
                            labels: {
                                align: 'right',
                                x: -3
                            },
                            title: {
                                text: 'Volume'
                            },
                            top: '65%',
                            height: '35%',
                            offset: 0,
                            lineWidth: 2
                     }],
                    tooltip: {
                        split: true
                      },
                    plotOptions: {
                        series : {
                            dataGrouping: {
                                units: groupingUnits
                            }
                        }
                        },

                    series: [{
                            type: 'candlestick',
                            name: 'AAPL',
                            id: 'aapl',
                            data: ohlc
                        }, {
                            type: 'column',
                            name: 'Volume',
                            id: 'volume',
                            data: volume,
                            yAxis: 1
                        },{
                            type: 'vbp',
                            linkedTo: 'aapl',
                            params: {
                                volumeSeriesID: 'volume'
                            },
                            dataLabels: {
                                enabled: false
                            },
                            zoneLines: {
                                enabled: false
                            }
                        },{
                            type: 'sma',
                            linkedTo: 'aapl',
                            zIndex: 1,
                            marker: {
                                enabled: false
                            }
                        }]
                });
            }
            createChart();
            </script>
            </body>
            </html>
            """
            return htmlContent
        }
    }
}

struct Charttwo: View {
    var symbol: String
    @State private var htmlContent = ""
    
    var body: some View {
        VStack {
            ChartWebView(symbol: symbol, htmlContent: $htmlContent) 
                .frame(height: 400)
        }
    }
}

struct Charttwo_Previews: PreviewProvider {
    static var previews: some View {
        Charttwo(symbol: "AAPL")
    }
}

struct ChartData: Codable {
    let timestamp: Int
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
}
