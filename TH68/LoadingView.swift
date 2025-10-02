//
//  LoadingView.swift
//  TH68
//
//  Created by IGOR on 02/10/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {

        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            VStack {
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 130)
            }
            
            VStack {
                
                Spacer()
                
                ProgressView()
                    .padding(40)
            }
        }
    }
}

#Preview {
    LoadingView()
}
