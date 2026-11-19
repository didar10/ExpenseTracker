//
//  SheetHeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.08.2026.
//

import SwiftUI

/// Шапка экранов, открываемых как bottom sheet:
/// заголовок по центру и кнопка закрытия слева.
struct SheetHeaderView<Trailing: View>: View {

    // MARK: - Properties

    let title: String
    let onClose: () -> Void
    let trailing: Trailing

    // MARK: - Init

    init(
        title: String,
        onClose: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.onClose = onClose
        self.trailing = trailing()
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppText(title, style: .bodySmall)

            HStack {
                ToolbarIconButton(icon: "xmark", isOutlined: true, action: onClose)

                Spacer()

                trailing
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .padding(.top, AppSpacing.medium)
    }
}

// MARK: - Init without trailing content

extension SheetHeaderView where Trailing == EmptyView {

    init(title: String, onClose: @escaping () -> Void) {
        self.init(title: title, onClose: onClose) {
            EmptyView()
        }
    }
}

#Preview {
    VStack {
        SheetHeaderView(title: "Заголовок") {}
    }
    .background(AppColor.background)
}
