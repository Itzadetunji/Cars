//
//  CarView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import SwiftUI

struct CarView: View {
    let carData: CarModel
    let activeDetent: PresentationDetent

    var body: some View {
        VStack(spacing: 10, ) {

            AsyncStickerImage(
                url: URL(string: carData.imageUrl),
                borderWidth: 40
            )
            .frame(maxHeight: 175)

            VStack(spacing: 12) {
                Text(String(format: "#%03d", carData.itemId)).font(
                    SofiaFont.semiBold(size: 14)
                ).foregroundStyle(Color.secondary)

                VStack(spacing: 12) {
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
                }

                CarBadgeView()

                VStack {

                    if activeDetent == .large {
                        HStack(spacing: 8) {
                            CarViewItem(
                                carData: carData,
                                informationType: .date
                            )
                            CarViewItem(
                                carData: carData,
                                informationType: .location
                            )
                            CarViewItem(
                                carData: carData,
                                informationType: .number
                            )
                        }.transition(
                            .opacity.combined(with: .move(edge: .bottom))
                                .animation(.easeInOut(duration: 0.25))
                        )

                        Button {

                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up").font(
                                    .system(size: 16, weight: .semibold)
                                )
                                Text("Share")
                            }
                            .frame(width: .infinity, height: 40)
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundStyle(.primary)
                        .buttonStyle(.glass)
                        .padding()
                        .transition(
                            .opacity.animation(.easeInOut(duration: 0.25))
                        )

                    }
                }.animation(
                    .spring(response: 0.4, dampingFraction: 0.8),
                    value: activeDetent
                )
            }
            Spacer()
        }.padding(.top, 40)
    }

}

#Preview {
    CarView(carData: sampleCar, activeDetent: .medium)
}
