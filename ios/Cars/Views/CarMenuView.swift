//
//  CarMenuView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 18/07/2026.
//

import SwiftUI

enum Categories: String, CaseIterable {
    case all, cars, airplanes, trains, helicopters, construction
}

struct CarMenuView: View {
    @State private var isShowingCategories = true
    @State private var selectedCategory = Categories.all
    @Namespace private var categoryNamespace

    //    print(Categories.allCases)
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Dim / blur the content behind when open
            VStack {
                if isShowingCategories {
                    // Expanded "button"
                    VStack {
                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible()),
                        ]) {
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
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white, in: RoundedRectangle(cornerRadius: 28))
                    .matchedGeometryEffect(
                        id: "categoryPicker",
                        in: categoryNamespace
                    )
                    //                    .padding(.top, 16)
                    .padding(.horizontal)
                } else {
                    Button {
                        withAnimation(
                            .spring(response: 0.35, dampingFraction: 0.85)
                        ) {
                            isShowingCategories = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 12, weight: .semibold))

                            Text("\(12) / \(12)")
                                .font(SofiaFont.bold(size: 14))

                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.secondary)

                        }.padding(.vertical, 4)
                    }.buttonStyle(.glass)
                        .matchedGeometryEffect(
                            id: "categoryPicker",
                            in: categoryNamespace
                        )
                }
            }
            
            Menu {
                ForEach(Categories.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Label(category.rawValue.capitalized, systemImage: "car")
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("\(12) / \(12)")
                    Image(systemName: "chevron.down")
                }
            }
        }
    }
}

#Preview {
    CarMenuView()
}
