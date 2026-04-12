//
//  HeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

struct HeaderView: View {

    // MARK: - Properties

    let title: String

    // MARK: - Body

    var body: some View {
        AppText(title, style: .title)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
            .background(AppColor.background)
    }
}

#Preview {
    HeaderView(title: "Главная")
}
