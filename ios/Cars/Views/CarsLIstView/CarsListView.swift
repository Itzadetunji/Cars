//
//  CarsListView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct CarsListView: View {
    private let items = Array(0..<5)
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(items, id: \.self) { _ in
                    CarsListItem()
                }
            }
        }.padding(.horizontal)
    }
}

#Preview {
    CarsListView()
}
