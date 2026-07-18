//
//  CarMenuView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 18/07/2026.
//

import SwiftUI

enum Categories: String, CaseIterable {
    case all, cars, airplanes, trains, construction

    var icons: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .airplanes: return "airplane"
        case .cars: return "car.fill"
        case .construction: return "truck.box.fill"
        case .trains: return "train.side.front.car"
        }
    }
}

struct CarMenuView: View {
    @State private var isShowingCategories = true
    @State private var selectedCategory = Categories.all
    @Namespace private var categoryNamespace

    //    print(Categories.allCases)
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Menu {
                Picker("Categories", selection: $selectedCategory) {
                    ForEach(Categories.allCases, id: \.self) {
                        category in
                        Button {
                            selectedCategory = category
                            withAnimation(
                                .spring(
                                    response: 0.35,
                                    dampingFraction: 0.55
                                )
                            ) {
                                isShowingCategories = false
                            }
                            isShowingCategories = false
                        } label: {
                            Image(systemName: category.icons)
                            Text(category.rawValue.capitalized)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .padding(10)
                                .background(
                                    selectedCategory == category
                                        ? Color(.systemGray5)
                                        : .clear,
                                    in: RoundedRectangle(
                                        cornerRadius: 12
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

            } label: {
                HStack(spacing: 6) {
                    Image(systemName: selectedCategory.icons)
                        .font(.system(size: 12, weight: .semibold))

                    Text("\(12) / \(12)")
                        .font(SofiaFont.bold(size: 14))

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)

                }.padding(.vertical, 4)
            }.buttonStyle(.glass)

        }
    }
}

#Preview {
    CarMenuView()
}
