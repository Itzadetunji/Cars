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
        Text(carData.name)
        Text(carData.description)
    }
}

#Preview {
    CarView(carData: sampleCar)
}



