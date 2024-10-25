////
////  News.swift
////  Stocksearch
////
////  Created by Rhushabh Madurwar on 4/12/24.
////
//
//import SwiftUI
//
//struct NewsItem: Codable, Identifiable {
//    let id: Int
//    let headline: String
//    let image: String
//    let source: String
//    let summary: String
//    let datetime: Int // You might want to convert this to a Date object later
//}
//class NewsViewModel: ObservableObject {
//    @Published var newsItems: [NewsItem] = []
//
//    func fetchNews(forSymbol symbol: String) {
//        let urlString = "http://localhost:3001/api/News?symbol=\(symbol)"
//        guard let url = URL(string: urlString) else { return }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data {
//                do {
//                    let decodedResponse = try JSONDecoder().decode([NewsItem].self, from: data)
//                    DispatchQueue.main.async {
//                        // Filter out items where the image URL is not available or empty
//                        self.newsItems = decodedResponse.filter { !$0.image.isEmpty }
//                    }
//                } catch {
//                    print("Decoding error: \(error)")
//                }
//            }
//        }.resume()
//    }
//}
//struct NewsView: View {
//    @ObservedObject var viewModel = NewsViewModel()
//    let symbol: String
//    
//    var body: some View {
//        
//        List(viewModel.newsItems.indices.dropFirst(), id: \.self) { index in
//            let item = viewModel.newsItems[index]
//            if(index == 1){
//                VStack(alignment: .leading, spacing: 4){
//                    if let imageUrl = URL(string: item.image), let imageData = try? Data(contentsOf: imageUrl), let uiImage =
//                        UIImage(data: imageData) {
//                        Image(uiImage: uiImage)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 300, height: 250)
//                    }
//                    Text(item.source)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    Text(item.headline)
//                        .font(.headline)
//                }
//            }else{
//                HStack {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(item.source)
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        Text(item.headline)
//                            .font(.headline)
//                    }
//                    if let imageUrl = URL(string: item.image), let imageData = try? Data(contentsOf: imageUrl), let uiImage = UIImage(data: imageData) {
//                        Image(uiImage: uiImage)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 80, height: 80)
//                    } else {
//                        Rectangle()
//                            .fill(Color.secondary)
//                            .frame(width: 80, height: 80)
//                    }
//                    //                VStack(alignment: .leading, spacing: 4) {
//                    //                    Text(item.headline)
//                    //                        .font(.headline)
//                    //                    Text(item.source)
//                    //                        .font(.subheadline)
//                    //                        .foregroundColor(.gray)
//                    //                }
//                }
//            }
//        }
//        .onAppear {
//            viewModel.fetchNews(forSymbol: symbol)
//        }
//    }
//}
//
//struct NewsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsView(symbol: "AAPL")
//    }
//}
//
