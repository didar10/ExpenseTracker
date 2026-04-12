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

    // MARK: - Settings

    static let settings = String(localized: "settings")
    static let general = String(localized: "general")
    static let defaultCurrency = String(localized: "default_currency")
    static let information = String(localized: "information")
    static let privacyPolicy = String(localized: "privacy_policy")
    static let helpAndSupport = String(localized: "help_and_support")
    static let termsOfService = String(localized: "terms_of_service")
    static let appVersion = String(localized: "app_version")
    static let contactSupport = String(localized: "contact_support")
    static let quickActions = String(localized: "quick_actions")
    static let faq = String(localized: "faq")
    static let noAnswerFound = String(localized: "no_answer_found")
    static let supportAvailable = String(localized: "support_available")
}
