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
            VStack(spacing: 0) {

                Image(.toyota)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background {
                        Image(.stamp1)
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.foreground)
                    }
                Text("Hello World").font(SofiaFont.black(size: 16)).padding(.vertical).foregroundStyle(.foreground)

            }
        }
        .padding(.horizontal, 3)

    }
}

#Preview {
    CarsListItem()
}
