//
//  LegalDocument.swift
//  ExpenseTracker
//
//  Created by Didar on 02.09.2026.
//

import SwiftUI

/// Правовой документ: политика конфиденциальности и условия использования
/// отличаются только содержимым, поэтому показываются одним экраном
struct LegalDocument {

    // MARK: - Section

    struct Section: Identifiable {
        let id = UUID()
        let title: String
        let content: String
    }

    // MARK: - Properties

    let title: String
    /// Короткий заголовок в шапке шторки
    let shortTitle: String
    let icon: Image
    let accentColor: Color
    let updatedAt: String
    var intro: String?
    let sections: [Section]

    // MARK: - Documents

    static let privacyPolicy = LegalDocument(
        title: AppString.privacyPolicy,
        shortTitle: AppString.privacyPolicyShort,
        icon: AppImage.handRaised,
        accentColor: AppColor.decorativePurple,
        updatedAt: AppString.lastUpdated,
        sections: [
            Section(title: AppString.privacySection1Title, content: AppString.privacySection1Content),
            Section(title: AppString.privacySection2Title, content: AppString.privacySection2Content),
            Section(title: AppString.privacySection3Title, content: AppString.privacySection3Content),
            Section(title: AppString.privacySection4Title, content: AppString.privacySection4Content),
            Section(title: AppString.privacySection5Title, content: AppString.privacySection5Content),
            Section(title: AppString.privacySection6Title, content: AppString.privacySection6Content)
        ]
    )

    static let termsOfService = LegalDocument(
        title: AppString.termsOfService,
        shortTitle: AppString.termsOfService,
        icon: AppImage.docText,
        // Красный означает в приложении расход и удаление — для документа берется акцент
        accentColor: AppColor.accent,
        updatedAt: AppString.lastUpdated,
        intro: AppString.termsIntro,
        sections: [
            Section(title: AppString.termsSection1Title, content: AppString.termsSection1Content),
            Section(title: AppString.termsSection2Title, content: AppString.termsSection2Content),
            Section(title: AppString.termsSection3Title, content: AppString.termsSection3Content),
            Section(title: AppString.termsSection4Title, content: AppString.termsSection4Content),
            Section(title: AppString.termsSection5Title, content: AppString.termsSection5Content),
            Section(title: AppString.termsSection6Title, content: AppString.termsSection6Content),
            Section(title: AppString.termsSection7Title, content: AppString.termsSection7Content),
            Section(title: AppString.termsSection8Title, content: AppString.termsSection8Content)
        ]
    )
}
