//
//  CarsListItem.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct CarsListItem: View {
    var carData: CarModel
    var onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 0) {
                carImage
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background {
                        Image(.stamp1)
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.foreground)
                    }

                Text(carData.name)
                    .font(SofiaFont.black(size: 16))
                    .padding(.top, 8)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 3)
    }

    @ViewBuilder
    private var carImage: some View {
        AsyncImage(url: URL(string: carData.imageUrl)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 80)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(.toyota)
                    .resizable()
                    .scaledToFit()
            @unknown default:
                EmptyView()
            }
        }.frame(maxHeight: 100)

    }
}

#Preview {
    CarsListItem(
        carData: sampleCar,
        onTap: {
            //
        }
    )
}
