//
//  CustomNavigationHeader.swift
//  ExpenseTracker
//
//  Created by Didar on 18.01.2026.
//

import SwiftUI

/// A custom navigation header that replaces the default navigationTitle
/// with a more flexible and customizable design
struct CustomNavigationHeader: View {
    
    let title: String
    let subtitle: String?
    let trailingButton: HeaderButton?
    
    init(
        title: String,
        subtitle: String? = nil,
        trailingButton: HeaderButton? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingButton = trailingButton
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if let button = trailingButton {
                Button {
                    button.action()
                } label: {
                    Image(systemName: button.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(button.color)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Header Button Model
struct HeaderButton {
    let icon: String
    let color: Color
    let action: () -> Void
    
    init(
        icon: String,
        color: Color = .green,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.action = action
    }
}

// MARK: - Scroll-Aware Header (Advanced)
/// A header that shrinks as you scroll down
struct ScrollAwareNavigationHeader: View {
    
    let title: String
    let subtitle: String?
    let scrollOffset: CGFloat
    let trailingButton: HeaderButton?
    
    private var progress: CGFloat {
        min(max(scrollOffset / 100, 0), 1)
    }
    
    private var titleSize: CGFloat {
        34 - (progress * 10) // Shrinks from 34 to 24
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        scrollOffset: CGFloat = 0,
        trailingButton: HeaderButton? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.scrollOffset = scrollOffset
        self.trailingButton = trailingButton
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: progress < 0.5 ? 4 : 2) {
                Text(title)
                    .font(.system(size: titleSize, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                if let subtitle, progress < 0.8 {
//                    Text(subtitle)
//                        .font(.system(size: 15 - (progress * 3), weight: .medium))
//                        .foregroundStyle(.secondary)
//                        .opacity(1 - (progress * 1.5))
                }
            }
            
            Spacer()
            
            if let button = trailingButton {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    button.action()
                } label: {
                    Image(systemName: button.icon)
                        .font(.system(size: 36 - (progress * 8)))
                        .foregroundStyle(button.color)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background {
            Color(.systemGroupedBackground)
                .opacity(progress)
                .ignoresSafeArea(edges: .top)
        }
    }
}

// MARK: - Preview
#Preview("Simple Header") {
    VStack {
        CustomNavigationHeader(
            title: "Главная",
            subtitle: "Управление финансами",
            trailingButton: HeaderButton(icon: "person.crop.circle.fill") {
                print("Profile tapped")
            }
        )
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Scroll-Aware Header") {
    ScrollView {
        VStack(spacing: 20) {
            ScrollAwareNavigationHeader(
                title: "Статистика",
                subtitle: "Анализ расходов",
                scrollOffset: 0,
                trailingButton: HeaderButton(icon: "square.and.arrow.up.circle.fill") {
                    print("Export tapped")
                }
            )
            
            ForEach(0..<20) { i in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .frame(height: 100)
                    .padding(.horizontal)
            }
        }
    }
    .background(Color(.systemGroupedBackground))
}
