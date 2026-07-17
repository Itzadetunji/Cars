//
//  CarBadgeView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 17/07/2026.
//

import SwiftUI

struct CarBadgeView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Image(systemName: "car.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Car")
                .font(SofiaFont.bold(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(.secondary.opacity(0.2), in: Capsule())
    }
}

#Preview {
    CarBadgeView()
}
