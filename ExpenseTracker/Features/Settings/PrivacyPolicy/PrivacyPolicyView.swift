//
//  PrivacyPolicyView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct PrivacyPolicyView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Введение
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Политика конфиденциальности")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Последнее обновление: 27 января 2026")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Раздел 1
                    PolicySectionView(
                        title: "1. Сбор информации",
                        content: """
                        ExpenseTracker собирает только ту информацию, которую вы добавляете вручную в приложение:
                        
                        • Финансовые транзакции (расходы и доходы)
                        • Названия категорий и счетов
                        • Суммы и даты операций
                        • Заметки к транзакциям
                        
                        Мы НЕ собираем:
                        • Персональные данные (имя, email, телефон)
                        • Данные банковских карт
                        • Информацию об устройстве
                        • Геолокацию
                        """
                    )
                    
                    // Раздел 2
                    PolicySectionView(
                        title: "2. Хранение данных",
                        content: """
                        Все ваши данные хранятся локально на вашем устройстве и не передаются на внешние серверы.
                        
                        • Данные сохраняются в защищенной базе данных устройства
                        • Доступ к данным имеете только вы
                        • Синхронизация через iCloud (опционально)
                        • Автоматическое резервное копирование в iCloud
                        """
                    )
                    
                    // Раздел 3
                    PolicySectionView(
                        title: "3. Использование данных",
                        content: """
                        Ваши данные используются исключительно для:
                        
                        • Отображения статистики расходов и доходов
                        • Создания отчетов и графиков
                        • Управления бюджетом
                        • Категоризации транзакций
                        
                        Мы никогда не:
                        • Продаем ваши данные третьим лицам
                        • Используем данные в маркетинговых целях
                        • Передаем информацию рекламодателям
                        """
                    )
                    
                    // Раздел 4
                    PolicySectionView(
                        title: "4. Безопасность",
                        content: """
                        Мы серьезно относимся к безопасности ваших данных:
                        
                        • Шифрование данных на устройстве
                        • Защита биометрией (Face ID / Touch ID)
                        • Безопасное резервное копирование
                        • Регулярные обновления безопасности
                        """
                    )
                    
                    // Раздел 5
                    PolicySectionView(
                        title: "5. Ваши права",
                        content: """
                        Вы имеете полный контроль над своими данными:
                        
                        • Экспорт всех данных в любое время
                        • Удаление аккаунта и всех данных
                        • Отключение синхронизации iCloud
                        • Очистка истории транзакций
                        """
                    )
                    
                    // Раздел 6
                    PolicySectionView(
                        title: "6. Контакты",
                        content: """
                        Если у вас есть вопросы о политике конфиденциальности, свяжитесь с нами:
                        
                        Email: support@expensetracker.app
                        Веб-сайт: www.expensetracker.app
                        
                        Мы ответим в течение 24 часов.
                        """
                    )
                }
                .padding()
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Конфиденциальность")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ToolbarIconButton(icon: "chevron.left") {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                }
            }
        }
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
    }
}

// MARK: - Policy Section View
struct PolicySectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
