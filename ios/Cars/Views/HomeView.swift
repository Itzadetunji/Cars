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
                ZStack {
                    CarsListView()
                    CameraViewButton()
                }
                VStack {
                    CarMenuView()
                    Spacer()
                }.padding(.top, 16)
               
            }
        }
    }
}

#Preview {
    HomeView()
}
