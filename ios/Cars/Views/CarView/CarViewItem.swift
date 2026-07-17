//
//  CarView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import SwiftUI

enum informationTypeEnum {
    case date, location, number
}

struct CarViewItem: View {
    let carData: CarModel
    var informationType: informationTypeEnum

    var body: some View {
        switch informationType {
        case .date:
            HStack(spacing: 3) {
                Image(systemName: "calendar").foregroundStyle(.secondary).font(
                    .system(size: 12, weight: .semibold)
                )
                Text("4 Jun 2026")
                    .font(SofiaFont.medium(size: 14)).foregroundStyle(
                        .secondary
                    )
            }
        case .location:
            HStack(spacing: 3) {
                Image(systemName: "map").foregroundStyle(.secondary).font(
                    .system(size: 12, weight: .semibold)
                )
                Text("4, Jun 2026").font(SofiaFont.medium(size: 14))
                    .foregroundStyle(
                        .secondary
                    )
            }

        case .number:
            HStack(spacing: 3) {
                Image(systemName: "number.sign").foregroundStyle(.secondary)
                    .font(.system(size: 12, weight: .semibold))
                Text("x\(carData.images.count)").font(
                    SofiaFont.medium(size: 14)
                )
                .foregroundStyle(
                    .secondary
                )
            }
        }
    }
}

#Preview {
    CarViewItem(carData: sampleCar, informationType: .date)
}
