//
//  FAQItem.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import Foundation

struct FAQItem: Identifiable {

    // MARK: - Properties

    let id = UUID()
    let question: String
    let answer: String

    // MARK: - Content

    static let all: [FAQItem] = [
        FAQItem(question: AppString.faqQ1, answer: AppString.faqA1),
        FAQItem(question: AppString.faqQ2, answer: AppString.faqA2),
        FAQItem(question: AppString.faqQ3, answer: AppString.faqA3),
        FAQItem(question: AppString.faqQ4, answer: AppString.faqA4),
        FAQItem(question: AppString.faqQ5, answer: AppString.faqA5),
        FAQItem(question: AppString.faqQ6, answer: AppString.faqA6),
        FAQItem(question: AppString.faqQ7, answer: AppString.faqA7),
        FAQItem(question: AppString.faqQ8, answer: AppString.faqA8)
    ]
}
