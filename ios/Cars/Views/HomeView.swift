//
//  HomeView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack{
            CarsListView()
            CameraViewButton()
        }
    }
}

#Preview {
    HomeView()
}
