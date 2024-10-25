//
//  AutoCompleteItemCard.swift
//  Stocksearch
//
//  Created by Rhushabh Madurwar on 4/7/24.
//
import SwiftUI
import SwiftData

import Foundation
struct AutocompleteItemCard: View {
    var item: AutocompleteItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.symbol)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical)
            Spacer()
        }
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
}

