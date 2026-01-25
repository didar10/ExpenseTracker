//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                AppText("Настройки", style: .title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
                    .background(Color(.systemGroupedBackground))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Основные настройки
                        VStack(spacing: 12) {
                            AppText("Основные", style: .sectionHeader, color: .secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 0) {
                                SettingsRowView(
                                    icon: "square.grid.2x2",
                                    iconColor: .blue,
                                    title: "Категории",
                                    destination: CategoriesListView()
                                )
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                SettingsRowView(
                                    icon: "dollarsign.circle",
                                    iconColor: .green,
                                    title: "Валюта по умолчанию",
                                    destination: PlansView()
                                )
                            }
                            .cardShadow(cornerRadius: 16)
                        }
                        
                        // MARK: - Информация
                        VStack(spacing: 12) {
                            AppText("Информация", style: .sectionHeader, color: .secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 0) {
                                SettingsRowView(
                                    icon: "hand.raised.fill",
                                    iconColor: .purple,
                                    title: "Политика конфиденциальности",
                                    destination: PlansView()
                                )
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                SettingsRowView(
                                    icon: "questionmark.circle",
                                    iconColor: .orange,
                                    title: "Помощь и поддержка",
                                    destination: PlansView()
                                )
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                SettingsRowView(
                                    icon: "doc.text",
                                    iconColor: .red,
                                    title: "Условия использования",
                                    destination: PlansView()
                                )
                            }
                            .cardShadow(cornerRadius: 16)
                        }
                        
                        // MARK: - App Info
                        VStack(spacing: 8) {
                            AppText("ExpenseTracker", style: .sectionHeader, color: .secondary)
                            
                            AppText("Версия 1.0.0", style: .caption, color: .secondary)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Settings Row View
struct SettingsRowView<Destination: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
                
                // Title
                AppText(title, style: .body)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray5) : Color.clear)
    }
}



