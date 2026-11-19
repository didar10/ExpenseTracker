//
//  SupportContact.swift
//  ExpenseTracker
//
//  Created by Didar on 02.09.2026.
//

import SwiftUI

/// Способ связи с поддержкой: подпись в списке и адрес, который открывает система
struct SupportContact: Identifiable {

    // MARK: - Properties

    let id = UUID()
    let icon: Image
    let iconColor: Color
    let title: String
    /// Человекочитаемый адрес: его же копирует контекстное меню
    let value: String
    let url: URL?

    // MARK: - Presets

    static let all: [SupportContact] = [email, website, telegram]

    static let email = SupportContact(
        icon: AppImage.envelope,
        iconColor: AppColor.accent,
        title: AppString.writeToUs,
        value: AppString.supportEmail,
        url: URL(string: "mailto:\(AppString.supportEmail)")
    )

    static let website = SupportContact(
        icon: AppImage.globe,
        iconColor: AppColor.income,
        title: AppString.website,
        value: AppString.supportWebsite,
        url: URL(string: "https://\(AppString.supportWebsite)")
    )

    static let telegram = SupportContact(
        icon: AppImage.message,
        iconColor: AppColor.decorativePurple,
        title: AppString.telegram,
        value: AppString.supportTelegram,
        url: URL(string: "https://t.me/\(AppString.supportTelegram.replacingOccurrences(of: "@", with: ""))")
    )
}
