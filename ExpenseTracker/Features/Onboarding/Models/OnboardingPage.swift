//
//  OnboardingPage.swift
//  ExpenseTracker
//
//  Created by Didar on 03.09.2026.
//

import SwiftUI

/// Страница приветственного экрана: по одной мысли на страницу,
/// порядок повторяет путь пользователя — записать, посмотреть, спланировать
enum OnboardingPage: Int, CaseIterable, Identifiable {

    case welcome
    case transactions
    case statistics
    case budgets

    // MARK: - Identifiable

    var id: Int { rawValue }

    // MARK: - Content

    var icon: Image {
        switch self {
        case .welcome: AppImage.onboardingWelcome
        case .transactions: AppImage.onboardingTransactions
        case .statistics: AppImage.onboardingStatistics
        case .budgets: AppImage.onboardingBudgets
        }
    }

    var title: String {
        switch self {
        case .welcome: AppString.onboardingWelcomeTitle
        case .transactions: AppString.onboardingTransactionsTitle
        case .statistics: AppString.onboardingStatisticsTitle
        case .budgets: AppString.onboardingBudgetsTitle
        }
    }

    var subtitle: String {
        switch self {
        case .welcome: AppString.onboardingWelcomeSubtitle
        case .transactions: AppString.onboardingTransactionsSubtitle
        case .statistics: AppString.onboardingStatisticsSubtitle
        case .budgets: AppString.onboardingBudgetsSubtitle
        }
    }

    /// Цвет страницы совпадает с цветом того же смысла в приложении:
    /// расходы — оранжевый, статистика — фиолетовый, бюджеты — зеленый
    var accentColor: Color {
        switch self {
        case .welcome: AppColor.accent
        case .transactions: AppColor.warning
        case .statistics: AppColor.decorativePurple
        case .budgets: AppColor.income
        }
    }
}
