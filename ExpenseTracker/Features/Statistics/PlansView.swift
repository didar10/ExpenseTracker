//
//  PlansView.swift
//  ExpenseTracker
//
//  Created by Didar on 04.01.2026.
//
import SwiftUI

struct PlansView: View {
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed header
                customHeader
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Функционал в разработке")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

private extension PlansView {
    var customHeader: some View {
        Text("Планы")
            .font(.system(size: 20, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
    }
}

