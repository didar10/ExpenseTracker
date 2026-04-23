//
//  AppString.swift
//  ExpenseTracker
//
//  Created by Didar on 09.04.2026.
//

import Foundation

enum AppString {

    // MARK: - Common

    static let currencyCode = "KZT"
    static let currencySymbol = "₸"
    static let save = String(localized: "save")
    static let cancel = String(localized: "cancel")
    static let delete = String(localized: "delete")
    static let done = String(localized: "done")
    static let today = String(localized: "today")
    static let yesterday = String(localized: "yesterday")
    static let income = String(localized: "income")
    static let expense = String(localized: "expense")
    static let noCategory = String(localized: "no_category")
    static let cannotUndo = String(localized: "cannot_undo")

    // MARK: - Dashboard

    static let balance = String(localized: "balance")
    static let noTransactions = String(localized: "no_transactions")
    static let noTransactionsHint = String(localized: "no_transactions_hint")
    static let deleteTransaction = String(localized: "delete_transaction")

    // MARK: - Accounts

    static let selectAccount = String(localized: "select_account")
    static let allAccounts = String(localized: "all_accounts")
    static let allAccountsHint = String(localized: "all_accounts_hint")
    static let noAccounts = String(localized: "no_accounts")
    static let noAccountsHint = String(localized: "no_accounts_hint")
    static let chooseAccount = String(localized: "choose_account")
    static let accountName = String(localized: "account_name")
    static let initialBalance = String(localized: "initial_balance")
    static let icon = String(localized: "icon")
    static let color = String(localized: "color")
    static let defaultAccount = String(localized: "default_account")
    static let defaultAccountHint = String(localized: "default_account_hint")
    static let deleteAccount = String(localized: "delete_account")
    static let deleteAccountConfirm = String(localized: "delete_account_confirm")
    static let deleteAccountMessage = String(localized: "delete_account_message")
    static let editAccount = String(localized: "edit_account")
    static let newAccount = String(localized: "new_account")

    // MARK: - AddExpense

    static let saved = String(localized: "saved")
    static let enterAmount = String(localized: "enter_amount")
    static let addComment = String(localized: "add_comment")
    static let selectDate = String(localized: "select_date")
    static let date = String(localized: "date")

    // MARK: - Categories

    static let allCategories = String(localized: "all_categories")
    static let noCategories = String(localized: "no_categories")
    static let createCategory = String(localized: "create_category")
    static let createCategoryHint = String(localized: "create_category_hint")
    static let categories = String(localized: "categories")
    static let deleteCategoryConfirm = String(localized: "delete_category_confirm")
    static let categoryName = String(localized: "category_name")
    static let enterName = String(localized: "enter_name")
    static let selectIcon = String(localized: "select_icon")
    static let selectColor = String(localized: "select_color")
    static let editCategory = String(localized: "edit_category")
    static let newCategory = String(localized: "new_category")
    static let saveChanges = String(localized: "save_changes")
    static let addCategoryHint = String(localized: "add_category_hint")
    static let name = String(localized: "name")

    // MARK: - Plans

    static let budgets = String(localized: "budgets")
    static let noBudgets = String(localized: "no_budgets")
    static let noBudgetsHint = String(localized: "no_budgets_hint")
    static let createBudget = String(localized: "create_budget")
    static let deleteBudgetConfirm = String(localized: "delete_budget_confirm")
    static let newBudget = String(localized: "new_budget")
    static let totalBudget = String(localized: "total_budget")
    static let spent = String(localized: "spent")
    static let remaining = String(localized: "remaining")
    static let exceeded = String(localized: "exceeded")
    static let category = String(localized: "category")
    static let limit = String(localized: "limit")
    static let period = String(localized: "period")
    static let allCategoriesUsed = String(localized: "all_categories_used")

    // MARK: - Statistics

    static let expenses = String(localized: "expenses")
    static let noData = String(localized: "no_data")
    static let noDataHint = String(localized: "no_data_hint")
    static let totalForPeriod = String(localized: "total_for_period")
    static let totalExpenses = String(localized: "total_expenses")
    static let noTransactionsForPeriod = String(localized: "no_transactions_for_period")
    static let amount = String(localized: "amount")
    static let periodWeek = String(localized: "statistics_period_week")
    static let periodMonth = String(localized: "statistics_period_month")
    static let periodLastMonth = String(localized: "statistics_period_last_month")
    static let periodYear = String(localized: "statistics_period_year")
    static let periodLastYear = String(localized: "statistics_period_last_year")
    static let periodAllTime = String(localized: "statistics_period_all_time")

    static func noTransactionsForPeriod(category: String) -> String {
        String(format: noTransactionsForPeriod, category)
    }

    // MARK: - Settings

    static let appName = String(localized: "app_name")
    static let settings = String(localized: "settings")
    static let general = String(localized: "general")
    static let defaultCurrency = String(localized: "default_currency")
    static let information = String(localized: "information")
    static let privacyPolicy = String(localized: "privacy_policy")
    static let privacyPolicyShort = String(localized: "privacy_policy_short")
    static let helpAndSupport = String(localized: "help_and_support")
    static let helpShort = String(localized: "help_short")
    static let termsOfService = String(localized: "terms_of_service")
    static let appVersion = String(localized: "app_version")
    static let contactSupport = String(localized: "contact_support")
    static let quickActions = String(localized: "quick_actions")
    static let faq = String(localized: "faq")
    static let noAnswerFound = String(localized: "no_answer_found")
    static let supportAvailable = String(localized: "support_available")
    static let helpSupportIntro = String(localized: "help_support_intro")
    static let writeToUs = String(localized: "write_to_us")
    static let website = String(localized: "website")
    static let telegram = String(localized: "telegram")
    static let supportEmail = String(localized: "support_email")
    static let supportWebsite = String(localized: "support_website")
    static let supportTelegram = String(localized: "support_telegram")
    static let lastUpdated = String(localized: "last_updated")
    static let termsIntro = String(localized: "terms_intro")

    // MARK: - FAQ

    static let faqQ1 = String(localized: "faq_q1")
    static let faqA1 = String(localized: "faq_a1")
    static let faqQ2 = String(localized: "faq_q2")
    static let faqA2 = String(localized: "faq_a2")
    static let faqQ3 = String(localized: "faq_q3")
    static let faqA3 = String(localized: "faq_a3")
    static let faqQ4 = String(localized: "faq_q4")
    static let faqA4 = String(localized: "faq_a4")
    static let faqQ5 = String(localized: "faq_q5")
    static let faqA5 = String(localized: "faq_a5")
    static let faqQ6 = String(localized: "faq_q6")
    static let faqA6 = String(localized: "faq_a6")
    static let faqQ7 = String(localized: "faq_q7")
    static let faqA7 = String(localized: "faq_a7")
    static let faqQ8 = String(localized: "faq_q8")
    static let faqA8 = String(localized: "faq_a8")

    // MARK: - Privacy Policy

    static let privacySection1Title = String(localized: "privacy_section_1_title")
    static let privacySection1Content = String(localized: "privacy_section_1_content")
    static let privacySection2Title = String(localized: "privacy_section_2_title")
    static let privacySection2Content = String(localized: "privacy_section_2_content")
    static let privacySection3Title = String(localized: "privacy_section_3_title")
    static let privacySection3Content = String(localized: "privacy_section_3_content")
    static let privacySection4Title = String(localized: "privacy_section_4_title")
    static let privacySection4Content = String(localized: "privacy_section_4_content")
    static let privacySection5Title = String(localized: "privacy_section_5_title")
    static let privacySection5Content = String(localized: "privacy_section_5_content")
    static let privacySection6Title = String(localized: "privacy_section_6_title")
    static let privacySection6Content = String(localized: "privacy_section_6_content")

    // MARK: - Terms of Service

    static let termsSection1Title = String(localized: "terms_section_1_title")
    static let termsSection1Content = String(localized: "terms_section_1_content")
    static let termsSection2Title = String(localized: "terms_section_2_title")
    static let termsSection2Content = String(localized: "terms_section_2_content")
    static let termsSection3Title = String(localized: "terms_section_3_title")
    static let termsSection3Content = String(localized: "terms_section_3_content")
    static let termsSection4Title = String(localized: "terms_section_4_title")
    static let termsSection4Content = String(localized: "terms_section_4_content")
    static let termsSection5Title = String(localized: "terms_section_5_title")
    static let termsSection5Content = String(localized: "terms_section_5_content")
    static let termsSection6Title = String(localized: "terms_section_6_title")
    static let termsSection6Content = String(localized: "terms_section_6_content")
    static let termsSection7Title = String(localized: "terms_section_7_title")
    static let termsSection7Content = String(localized: "terms_section_7_content")
    static let termsSection8Title = String(localized: "terms_section_8_title")
    static let termsSection8Content = String(localized: "terms_section_8_content")
}
