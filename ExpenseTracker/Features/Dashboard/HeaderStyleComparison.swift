//
//  HeaderStyleComparison.swift
//  ExpenseTracker
//
//  Created by Didar on 18.01.2026.
//
//  This file shows all header styles side by side for comparison

import SwiftUI

struct HeaderStyleComparison: View {
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section("1. Simple Custom Header (Current)") {
                    CustomNavigationHeader(
                        title: "Главная",
                        subtitle: "Управление финансами",
                        trailingButton: HeaderButton(
                            icon: "person.crop.circle.fill",
                            action: { }
                        )
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section("2. Without Subtitle") {
                    CustomNavigationHeader(
                        title: "Главная",
                        trailingButton: HeaderButton(
                            icon: "gear",
                            action: { }
                        )
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section("3. Without Button") {
                    CustomNavigationHeader(
                        title: "Статистика",
                        subtitle: "Анализ расходов"
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section("4. Minimal") {
                    CustomNavigationHeader(title: "Настройки")
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                Section("5. Scroll-Aware (Not Scrolled)") {
                    ScrollAwareNavigationHeader(
                        title: "Главная",
                        subtitle: "Управление финансами",
                        scrollOffset: 0,
                        trailingButton: HeaderButton(
                            icon: "person.crop.circle.fill",
                            action: { }
                        )
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section("6. Scroll-Aware (Scrolled 50%)") {
                    ScrollAwareNavigationHeader(
                        title: "Главная",
                        subtitle: "Управление финансами",
                        scrollOffset: 50,
                        trailingButton: HeaderButton(
                            icon: "person.crop.circle.fill",
                            action: { }
                        )
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section("7. Scroll-Aware (Fully Scrolled)") {
                    ScrollAwareNavigationHeader(
                        title: "Главная",
                        subtitle: "Управление финансами",
                        scrollOffset: 100,
                        trailingButton: HeaderButton(
                            icon: "person.crop.circle.fill",
                            action: { }
                        )
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section("8. Custom Colors") {
                    CustomNavigationHeader(
                        title: "Профиль",
                        subtitle: "Настройки аккаунта",
                        trailingButton: HeaderButton(
                            icon: "bell.fill",
                            color: .orange,
                            action: { }
                        )
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section("9. Multiple Action Buttons") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Сообщения")
                                .font(.system(size: 34, weight: .bold))
                            Text("3 новых")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button { } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.green)
                            }
                            
                            Button { } label: {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.green)
                                    .symbolRenderingMode(.hierarchical)
                            }
                        }
                    }
                    .padding()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section("10. Compact Style") {
                    HStack {
                        Text("Категории")
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                        
                        Button { } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.green)
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .padding()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Header Styles")
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - Animated Header Examples

struct AnimatedHeaderExamples: View {
    
    @State private var showHeader1 = false
    @State private var showHeader2 = false
    @State private var showHeader3 = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Slide from Top")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        CustomNavigationHeader(
                            title: "Добро пожаловать",
                            subtitle: "Начните управлять финансами"
                        )
                        .offset(y: showHeader1 ? 0 : -100)
                        .opacity(showHeader1 ? 1 : 0)
                    }
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Fade In")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        CustomNavigationHeader(
                            title: "Статистика",
                            subtitle: "Ваш прогресс"
                        )
                        .opacity(showHeader2 ? 1 : 0)
                        .scaleEffect(showHeader2 ? 1 : 0.9)
                    }
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Slide from Bottom")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        CustomNavigationHeader(
                            title: "Готово",
                            subtitle: "Успешно сохранено"
                        )
                        .offset(y: showHeader3 ? 0 : 50)
                        .opacity(showHeader3 ? 1 : 0)
                    }
                }
                
                Button("Replay Animations") {
                    showHeader1 = false
                    showHeader2 = false
                    showHeader3 = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        playAnimations()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            playAnimations()
        }
    }
    
    private func playAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showHeader1 = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showHeader2 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showHeader3 = true
            }
        }
    }
}

// MARK: - Previews

#Preview("All Styles") {
    HeaderStyleComparison()
}

#Preview("Animated") {
    AnimatedHeaderExamples()
}
