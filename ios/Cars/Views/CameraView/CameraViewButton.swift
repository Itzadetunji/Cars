//
//  CameraViewButton.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct CameraViewButton: View {
    var body: some View {
        VStack {
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "camera")
                    .foregroundStyle(.white)
            }.buttonStyle(.plain)
                .frame(width: 60, height: 60)
                .background(.black)
                .cornerRadius(.infinity)
        }
    }
}

#Preview {
    CameraViewButton()
}
