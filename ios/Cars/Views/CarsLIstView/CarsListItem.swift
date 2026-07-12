//
//  CarsListItem.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct CarsListItem: View {
    var body: some View {
        Button {
            
        } label: {
            Text("Hello World")
                .frame(maxWidth: .infinity, minHeight: 80)
        }
        .buttonStyle(.plain)
        .padding(10)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 2)
            
    }
}

#Preview {
    CarsListItem()
}
