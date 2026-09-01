//
//  SectionHeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Заголовок дня в списке операций. Прилипает к верху списка при прокрутке,
/// поэтому рисует непрозрачный фон
struct SectionHeaderView: View {

    // MARK: - Properties

    let date: Date

    /// Формат берется из локали устройства, а не задается строкой:
    /// пересоздавать DateFormatter на каждый рендер строки списка дорого
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEdMMMM")
        return formatter
    }()

    // MARK: - Computed Properties

    private var dateTitle: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return AppString.today
        }

        if calendar.isDateInYesterday(date) {
            return AppString.yesterday
        }

        return Self.dayFormatter.string(from: date).capitalizingFirstLetter
    }

    // MARK: - Body

    var body: some View {
        AppText(dateTitle, style: .bodySmaller)
            .color(AppColor.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.xSmall)
            .padding(.top, AppSpacing.small)
            .padding(.bottom, AppSpacing.smaller)
            .background(AppColor.background)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    VStack(alignment: .leading) {
        SectionHeaderView(date: .now)
        SectionHeaderView(date: .now.addingTimeInterval(-86_400))
        SectionHeaderView(date: .now.addingTimeInterval(-86_400 * 5))
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}
