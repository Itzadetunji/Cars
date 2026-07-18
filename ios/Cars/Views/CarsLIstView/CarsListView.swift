//
//  CarsListView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct CarsListView: View {
    @State private var selectedCar: CarModel?
    @State private var activeDetent: PresentationDetent = .medium

    @State private var cars = sampleCars
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {

                ForEach(cars) { car in
                    CarsListItem(
                        carData: car,
                        onTap: {
                            selectedCar = car
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
        .sheet(item: $selectedCar) { car in
            CarView(carData: car, activeDetent: activeDetent)
                .presentationDetents([.fraction(0.5), .large], selection: $activeDetent)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    CarsListView()
}
