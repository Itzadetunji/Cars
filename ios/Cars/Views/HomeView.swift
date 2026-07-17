//
//  HomeView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            //            LatestCarView()
            ZStack {
                CarsListView()
                CameraViewButton()
            }
        }
    }
}

#Preview {
    HomeView()
}
