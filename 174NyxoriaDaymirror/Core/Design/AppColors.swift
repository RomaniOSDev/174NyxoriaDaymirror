//
//  AppColors.swift
//  174NyxoriaDaymirror
//

import SwiftUI

extension Color {
    static let appBackground = Color("AppBackground")
    static let appSurface = Color("AppSurface")
    static let appPrimary = Color("AppPrimary")
    static let appAccent = Color("AppAccent")
    static let appTextPrimary = Color("AppTextPrimary")
    static let appTextSecondary = Color("AppTextSecondary")
}

struct NyxoriaDaymirrorLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.8)
                    .padding(.top, 30)
            }
        }
    }
}
