//
//  IconPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    let onSelect: (String) -> Void
    
    private let icons = [
        "creditcard.fill",
        "wallet.pass.fill",
        "banknote.fill",
        "tengesign.circle.fill",
        "building.columns.fill",
        "briefcase.fill"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                        onSelect(icon)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color(uiColor: .secondarySystemBackground))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundStyle(selectedIcon == icon ? .blue : .secondary)
                        }
                    }
                }
            }
        }
    }
}
