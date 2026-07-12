//
//  CarsListView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct CarsListView: View {
    private let items = Array(0...50)
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items, id: \.self) { _ in
                    CarsListItem()
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CarsListView()
}
