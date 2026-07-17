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

                VStack(spacing: -2) {
                    Text(String(format: "#%03d", carData.itemId)).font(
                        SofiaFont.semiBold(size: 14) 
                    ).foregroundStyle(Color.secondary)

                    Text(carData.name)
                        .font(SofiaFont.bold(size: 16))
                        .padding(.top, 8)
                        .blur(radius: 4)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 3)
    }

    @ViewBuilder
    private var carImage: some View {
        AsyncStickerImage(url: URL(string: carData.imageUrl), borderWidth: 30)
            .frame(maxHeight: 100)
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
