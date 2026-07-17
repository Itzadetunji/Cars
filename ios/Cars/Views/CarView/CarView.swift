//
//  CarView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import SwiftUI

struct CarView: View {
    let carData: CarModel

    var body: some View {
        VStack(spacing: 10, ) {

            AsyncStickerImage(
                url: URL(string: carData.imageUrl),
                borderWidth: 40
            )
            .frame(maxHeight: 175)
            VStack(spacing: 8) {
                Text(String(format: "#%03d", carData.itemId)).font(
                    SofiaFont.semiBold(size: 14)
                ).foregroundStyle(Color.secondary)

                Text(carData.name)
                    .font(SofiaFont.bold(size: 18))
                    .padding(.top, 8)
                    .blur(radius: 4)

                Text("Not discovered yet")
                    .font(SofiaFont.regular(size: 14))
                    .foregroundStyle(.secondary)

                Text(carData.description)
                    .font(SofiaFont.regular(size: 16))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)

                CarBadgeView()

                HStack (spacing: 8) {
                    CarViewItem(carData: carData, informationType: .date)
                    CarViewItem(carData: carData, informationType: .location)
                    CarViewItem(carData: carData, informationType: .number)
                }
            }
            Spacer()
        }.padding(.top, 40)
    }

}

#Preview {
    CarView(carData: sampleCar)
}
