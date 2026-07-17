//
//  LatestCarView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 17/07/2026.
//

import SwiftUI

struct LatestCarView: View {
    var body: some View {

        AsyncImage(
            url: URL(
                string:
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg/1280px-Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg"
            )
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    LatestCarView()
}
