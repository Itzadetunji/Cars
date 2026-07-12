//
//  CarsListItem.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct CarsListItem: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button {
            
        } label: {
            Text("Hello World").font(SofiaFont.black(size: 16))
                .frame(maxWidth: .infinity, minHeight: 100)
                
        }
        .buttonStyle(.plain)
        
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(
            color: (colorScheme == .dark ? Color.white : Color.black).opacity(0.12),
            radius: 2,
            x: 0,
            y: 2
        )
        .padding(.horizontal, 3)
            
    }
}

#Preview {
    CarsListItem()
}
