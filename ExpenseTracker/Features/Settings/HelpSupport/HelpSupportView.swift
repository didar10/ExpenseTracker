//
//  HelpSupportView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct HelpSupportView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    @State private var expandedFAQ: UUID?
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Введение
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue.gradient)
                        
                        Text("Помощь и поддержка")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Найдите ответы на часто задаваемые вопросы или свяжитесь с нами")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Быстрые действия
                    VStack(spacing: 12) {
                        Text("Быстрые действия")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 0) {
                            QuickActionRow(
                                icon: "envelope.fill",
                                iconColor: .blue,
                                title: "Написать нам",
                                subtitle: "support@expensetracker.app"
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            QuickActionRow(
                                icon: "globe",
                                iconColor: .green,
                                title: "Сайт",
                                subtitle: "www.expensetracker.app"
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            QuickActionRow(
                                icon: "message.fill",
                                iconColor: .purple,
                                title: "Telegram",
                                subtitle: "@expensetracker_support"
                            )
                        }
                        .cardShadow(cornerRadius: 16)
                    }
                    
                    // FAQ
                    VStack(spacing: 12) {
                        Text("Частые вопросы")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 8) {
                            ForEach(faqItems) { item in
                                FAQItemView(
                                    item: item,
                                    isExpanded: expandedFAQ == item.id
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        expandedFAQ = expandedFAQ == item.id ? nil : item.id
                                    }
                                }
                            }
                        }
                    }
                    
                    // Дополнительная помощь
                    VStack(spacing: 16) {
                        Text("Не нашли ответ?")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Наша команда поддержки готова помочь вам 24/7")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            // Действие отправки email
                        } label: {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Связаться с поддержкой")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.vertical, 20)
                }
                .padding()
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Помощь")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .shadow(
                                color: .black.opacity(0.1),
                                radius: 3,
                                x: 0,
                                y: 2
                            )
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
    }
}

// MARK: - FAQ Item
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - FAQ Data
private let faqItems = [
    FAQItem(
        question: "Как добавить новую транзакцию?",
        answer: "Нажмите на большую кнопку '+' внизу экрана. Выберите тип транзакции (расход или доход), укажите сумму, категорию и дату. Нажмите 'Сохранить'."
    ),
    FAQItem(
        question: "Как создать новую категорию?",
        answer: "Перейдите в Настройки → Категории → нажмите '+' в правом верхнем углу. Введите название, выберите иконку и цвет для категории."
    ),
    FAQItem(
        question: "Как изменить валюту?",
        answer: "Откройте Настройки → Валюта по умолчанию → выберите нужную валюту из списка. Все суммы будут отображаться в выбранной валюте."
    ),
    FAQItem(
        question: "Безопасны ли мои данные?",
        answer: "Да! Все данные хранятся локально на вашем устройстве и шифруются. Мы не передаем ваши данные третьим лицам. Опционально можно включить синхронизацию через iCloud."
    ),
    FAQItem(
        question: "Как посмотреть статистику?",
        answer: "Откройте вкладку 'Статистика' внизу экрана. Вы увидите круговую диаграмму расходов по категориям и детальную статистику за выбранный период."
    ),
    FAQItem(
        question: "Можно ли экспортировать данные?",
        answer: "Да, вы можете экспортировать все транзакции в формате CSV или PDF. Перейдите в Настройки → Экспорт данных."
    ),
    FAQItem(
        question: "Как удалить транзакцию?",
        answer: "Нажмите на транзакцию в списке, затем нажмите кнопку 'Редактировать'. В открывшемся окне внизу есть кнопка 'Удалить транзакцию'."
    ),
    FAQItem(
        question: "Работает ли приложение офлайн?",
        answer: "Да! ExpenseTracker полностью работает без интернета. Все данные сохраняются локально на вашем устройстве."
    )
]

// MARK: - Quick Action Row
struct QuickActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
    }
}

// MARK: - FAQ Item View
struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.question)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                
                Text(item.answer)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    NavigationStack {
        HelpSupportView()
    }
}
