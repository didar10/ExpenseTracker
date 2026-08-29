//
//  ScreenHeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import SwiftUI

/// Шапка экранов вкладок вместо системного навбара:
/// заголовок по центру и кнопки по краям на одинаковой для всех экранов высоте.
struct ScreenHeaderView<Leading: View, Trailing: View>: View {

    // MARK: - Properties

    let title: String
    let leading: Leading
    let trailing: Trailing

    // MARK: - Init

    init(
        title: String,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppText(title, style: .section, alignment: .center)

            HStack(spacing: AppSpacing.small) {
                leading

                Spacer()

                trailing
            }
        }
        .frame(maxWidth: .infinity, minHeight: AppSize.toolbarButton)
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .background(AppColor.background)
    }
}

// MARK: - Init without leading content

extension ScreenHeaderView where Leading == EmptyView {

    init(title: String, @ViewBuilder trailing: () -> Trailing) {
        self.init(title: title, leading: { EmptyView() }, trailing: trailing)
    }
}

// MARK: - Init without buttons

extension ScreenHeaderView where Leading == EmptyView, Trailing == EmptyView {

    init(title: String) {
        self.init(title: title, leading: { EmptyView() }, trailing: { EmptyView() })
    }
}

#Preview {
    VStack(spacing: .zero) {
        ScreenHeaderView(title: "Настройки")

        ScreenHeaderView(title: "Бюджеты") {
            EditToggleButton(isEditing: false, action: {})

            ToolbarIconButton(icon: "plus", isOutlined: true, action: {})
        }
    }
    .background(AppColor.background)
}
