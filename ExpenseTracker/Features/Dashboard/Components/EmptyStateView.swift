//
//  EmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент для отображения пустого состояния
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                AppText("Нет транзакций", style: .title)
                
                AppText("Нажмите + чтобы добавить первую транзакцию", style: .bodySmall, color: .secondary, alignment: .center)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView()
}
