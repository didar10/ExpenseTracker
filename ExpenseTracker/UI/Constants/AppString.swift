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
    /// Неразрывный пробел между разрядами суммы: 1 350 000
    static let amountGroupingSeparator = "\u{00A0}"
    static let save = String(localized: "save")
    static let cancel = String(localized: "cancel")
    static let ok = String(localized: "ok")
    static let delete = String(localized: "delete")
    static let done = String(localized: "done")
    static let today = String(localized: "today")
    static let yesterday = String(localized: "yesterday")
    static let income = String(localized: "income")
    static let expense = String(localized: "expense")
    static let noCategory = String(localized: "no_category")
    static let cannotUndo = String(localized: "cannot_undo")
    static let more = String(localized: "more")
    static let copy = String(localized: "copy")

    // MARK: - Dashboard

    static let balance = String(localized: "balance")
    static let noTransactions = String(localized: "no_transactions")
    static let noTransactionsHint = String(localized: "no_transactions_hint")
    static let noTransactionsInPeriod = String(localized: "no_transactions_in_period")
    static let deleteTransaction = String(localized: "delete_transaction")
    static let repeatTransaction = String(localized: "repeat_transaction")
    static let transactionDeleted = String(localized: "transaction_deleted")
    static let undo = String(localized: "undo")
    static let onAccounts = String(localized: "on_accounts")
    static let balanceAllTime = String(localized: "balance_all_time")
    static let noTransactionsYet = String(localized: "no_transactions_yet")
    static let duplicateTransaction = String(localized: "duplicate_transaction")
    static let openStatisticsHint = String(localized: "open_statistics_hint")
    static let editTransactionHint = String(localized: "edit_transaction_hint")
    /// Разделитель «Все счета · Ноябрь» в компактной шапке
    static let titleSeparator = " · "

    // MARK: - Persistence

    static let saveFailedTitle = String(localized: "save_failed_title")
    static let saveFailedMessage = String(localized: "save_failed_message")
    static let dataUnavailableTitle = String(localized: "data_unavailable_title")
    static let dataUnavailableMessage = String(localized: "data_unavailable_message")

    // MARK: - Monthly Limit

    static let canSpendToday = String(localized: "can_spend_today")
    static let overspentToday = String(localized: "overspent_today")
    static let monthlyLimitExceeded = String(localized: "monthly_limit_exceeded")
    static let monthlyLimitTitle = String(localized: "monthly_limit_title")
    static let monthlyLimitDescription = String(localized: "monthly_limit_description")
    static let monthlyLimitPromptTitle = String(localized: "monthly_limit_prompt_title")
    static let monthlyLimitPromptHint = String(localized: "monthly_limit_prompt_hint")
    static let removeMonthlyLimit = String(localized: "remove_monthly_limit")
    static let showLimitOnDashboard = String(localized: "show_limit_on_dashboard")
    static let toggleOn = String(localized: "toggle_on")
    static let toggleOff = String(localized: "toggle_off")
    private static let ofAmount = String(localized: "of_amount")
    private static let spentPercent = String(localized: "spent_percent")
    private static let monthRemainingDays = String(localized: "month_remaining_days")
    private static let monthlyLimitFooter = String(localized: "monthly_limit_footer")
    private static let monthlyLimitPerDayHint = String(localized: "monthly_limit_per_day_hint")

    static func ofAmount(_ amount: String) -> String {
        String(format: ofAmount, amount)
    }

    /// «Потрачено 61%»
    static func spentPercent(_ percent: Int) -> String {
        String(format: spentPercent, percent)
    }

    /// «Осталось 118 050 ₸ · 11 дн.»
    static func monthRemainingDays(_ amount: String, _ days: Int) -> String {
        String(format: monthRemainingDays, amount, days)
    }

    static func monthlyLimitFooter(_ amount: String) -> String {
        String(format: monthlyLimitFooter, amount)
    }

    static func monthlyLimitPerDayHint(_ amount: String) -> String {
        String(format: monthlyLimitPerDayHint, amount)
    }

    static func noTransactionsInPeriod(_ period: String) -> String {
        String(format: noTransactionsInPeriod, period)
    }

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
    /// Короткая подпись плавающей кнопки в списке счетов
    static let newAccountShort = String(localized: "new_account_short")
    static let createAccount = String(localized: "create_account")
    static let addAccount = String(localized: "add_account")
    static let addAccountHint = String(localized: "add_account_hint")

    // MARK: - AddExpense

    static let saved = String(localized: "saved")
    static let enterAmount = String(localized: "enter_amount")
    static let addComment = String(localized: "add_comment")
    static let selectDate = String(localized: "select_date")
    static let date = String(localized: "date")
    static let newTransaction = String(localized: "new_transaction")
    static let editTransaction = String(localized: "edit_transaction")
    static let discardChangesTitle = String(localized: "discard_changes_title")
    static let discardChangesMessage = String(localized: "discard_changes_message")
    static let discardChanges = String(localized: "discard_changes")
    static let discardAccountTitle = String(localized: "discard_account_title")
    static let discardCategoryTitle = String(localized: "discard_category_title")
    static let keepEditing = String(localized: "keep_editing")
    static let noCategoriesForType = String(localized: "no_categories_for_type")
    static let dayBeforeYesterday = String(localized: "day_before_yesterday")
    static let transactionType = String(localized: "transaction_type")
    static let accountSheetTitle = String(localized: "account_sheet_title")
    static let newAccountButton = String(localized: "new_account_button")
    static let notePlaceholder = String(localized: "note_placeholder")
    static let findCategory = String(localized: "find_category")
    static let nothingFound = String(localized: "nothing_found")
    static let saveExpense = String(localized: "save_expense")
    static let saveIncome = String(localized: "save_income")
    static let checkAmount = String(localized: "check_amount")
    static let deleteTransactionTitle = String(localized: "delete_transaction_title")
    static let deleteTransactionLabel = String(localized: "delete_transaction_label")
    static let time = String(localized: "time")
    static let timeEarlier = String(localized: "time_earlier")
    static let timeLater = String(localized: "time_later")
    static let previousMonth = String(localized: "previous_month")
    static let nextMonth = String(localized: "next_month")

    /// «= Сохранить 2 000 ₸»: знак «=» рисует кнопка
    static func saveAmount(_ amount: String) -> String {
        String(format: String(localized: "save_amount"), amount)
    }

    /// «Продукты на неделю −4 850 ₸. Баланс счёта пересчитается.»
    static func deleteTransactionMessage(title: String, amount: String) -> String {
        String(format: String(localized: "delete_transaction_message"), title, amount)
    }

    /// «18 400 ₸ в ноябре»; month — 1…12
    static func spentInMonth(_ amount: String, month: Int) -> String {
        // Ключ собирается в рантайме: интерполяция в LocalizationValue дала бы ключ «month_in_%lld»
        let monthName = Bundle.main.localizedString(forKey: "month_in_\(month)", value: nil, table: nil)
        return String(format: String(localized: "spent_in_month"), amount, monthName)
    }

    // MARK: - Accessibility

    static let accessibilityClose = String(localized: "accessibility_close")
    static let accessibilityDeleteDigit = String(localized: "accessibility_delete_digit")
    static let accessibilityClearAmount = String(localized: "accessibility_clear_amount")
    static let accessibilityDecimalSeparator = String(localized: "accessibility_decimal_separator")
    static let accessibilityAmount = String(localized: "accessibility_amount")

    // MARK: - Categories

    static let allCategories = String(localized: "all_categories")
    static let noCategories = String(localized: "no_categories")
    static let createCategory = String(localized: "create_category")
    static let createCategoryHint = String(localized: "create_category_hint")
    static let categories = String(localized: "categories")
    static let deleteCategoryConfirm = String(localized: "delete_category_confirm")
    static let deleteCategoryMessage = String(localized: "delete_category_message")
    static let deleteCategoryWithBudgetMessage = String(localized: "delete_category_with_budget_message")
    static let categoryName = String(localized: "category_name")
    static let enterName = String(localized: "enter_name")
    static let selectIcon = String(localized: "select_icon")
    static let selectColor = String(localized: "select_color")
    static let editCategory = String(localized: "edit_category")
    static let newCategory = String(localized: "new_category")
    static let saveChanges = String(localized: "save_changes")
    static let addCategoryHint = String(localized: "add_category_hint")
    static let name = String(localized: "name")
    static let edit = String(localized: "edit")
    static let addNew = String(localized: "add_new")
    static let categoryNameExample = String(localized: "category_name_example")

    // MARK: - Budgets

    static let budgets = String(localized: "budgets")
    static let deleteBudgetConfirm = String(localized: "delete_budget_confirm")
    static let newBudget = String(localized: "new_budget")
    static let createBudget = String(localized: "create_budget")
    static let addBudgetPerMonth = String(localized: "add_budget_per_month")
    static let addBudgetSwipeHint = String(localized: "add_budget_swipe_hint")
    static let addBudgetPresetMinusTen = String(localized: "add_budget_preset_minus_ten")
    static let addBudgetPresetThreeMonths = String(localized: "add_budget_preset_three_months")
    static let addBudgetCarryOver = String(localized: "add_budget_carry_over")
    static let addBudgetWarnNearLimit = String(localized: "add_budget_warn_near_limit")
    static let addBudgetPeriod = String(localized: "add_budget_period")
    private static let addBudgetUnallocatedHintFormat = String(localized: "add_budget_unallocated_hint")
    private static let addBudgetOverLimitHintFormat = String(localized: "add_budget_over_limit_hint")

    /// «Из лимита 250 000 ₸ останется нераспределено 20 000 ₸»
    static func addBudgetUnallocatedHint(_ limit: String, _ rest: String) -> String {
        String(format: addBudgetUnallocatedHintFormat, limit, rest)
    }

    /// «Бюджеты превысят лимит 250 000 ₸ на 5 000 ₸»
    static func addBudgetOverLimitHint(_ limit: String, _ excess: String) -> String {
        String(format: addBudgetOverLimitHintFormat, limit, excess)
    }

    /// «в октябре 18 400 ₸» — подпись категории в ленте нового бюджета
    static func addBudgetSpentInMonth(_ amount: String, month: Int) -> String {
        // Ключ собирается в рантайме — как в `spentInMonth`
        let monthName = Bundle.main.localizedString(forKey: "month_in_\(month)", value: nil, table: nil)
        return String(format: String(localized: "add_budget_spent_in_month"), monthName, amount)
    }
    static let category = String(localized: "category")
    static let budgetsChooseMonthHint = String(localized: "budgets_choose_month_hint")
    private static let budgetsEditLimitLabelFormat = String(localized: "budgets_edit_limit_label")
    static let budgetsLeft = String(localized: "budgets_left")
    static let budgetsOverLimit = String(localized: "budgets_over_limit")
    private static let budgetsSpentFormat = String(localized: "budgets_spent")
    private static let budgetsPerDayFormat = String(localized: "budgets_per_day")
    static let budgetsPaceNormal = String(localized: "budgets_pace_normal")
    static let budgetsPaceFast = String(localized: "budgets_pace_fast")
    static let budgetsPaceLimitExceeded = String(localized: "budgets_pace_limit_exceeded")
    private static let budgetsPaceSlowerFormat = String(localized: "budgets_pace_slower")
    private static let budgetsPaceFasterFormat = String(localized: "budgets_pace_faster")
    static let budgetsPaceExact = String(localized: "budgets_pace_exact")
    private static let budgetsPaceExceededByFormat = String(localized: "budgets_pace_exceeded_by")
    static let budgetsLimitPromptTitle = String(localized: "budgets_limit_prompt_title")
    static let budgetsLimitPromptHint = String(localized: "budgets_limit_prompt_hint")
    static let budgetsCategories = String(localized: "budgets_categories")
    private static let budgetsAllocatedOfFormat = String(localized: "budgets_allocated_of")
    private static let budgetsAllocatedFormat = String(localized: "budgets_allocated")
    private static let budgetsSpentOfLimitFormat = String(localized: "budgets_spent_of_limit")
    static let budgetsBadgeExceeded = String(localized: "budgets_badge_exceeded")
    private static let budgetsPercentFormat = String(localized: "budgets_percent")
    private static let budgetsLeftPerDayFormat = String(localized: "budgets_left_per_day")
    private static let budgetsLeftAmountFormat = String(localized: "budgets_left_amount")
    private static let budgetsExceededByFormat = String(localized: "budgets_exceeded_by")
    static let budgetsLimitUsedUp = String(localized: "budgets_limit_used_up")
    static let budgetsAddCategoryBudget = String(localized: "budgets_add_category_budget")
    private static let budgetsUnallocatedFormat = String(localized: "budgets_unallocated")
    private static let budgetsOverAllocatedFormat = String(localized: "budgets_over_allocated")
    static let budgetsEmptyTitle = String(localized: "budgets_empty_title")
    static let budgetsEmptyHint = String(localized: "budgets_empty_hint")
    static let budgetsSetMonthlyLimit = String(localized: "budgets_set_monthly_limit")
    static let budgetsHowItWorks = String(localized: "budgets_how_it_works")
    static let budgetsStepLimitTitle = String(localized: "budgets_step_limit_title")
    static let budgetsStepLimitSubtitle = String(localized: "budgets_step_limit_subtitle")
    static let budgetsStepCategoriesTitle = String(localized: "budgets_step_categories_title")
    static let budgetsStepCategoriesSubtitle = String(localized: "budgets_step_categories_subtitle")
    static let budgetsStepHintsTitle = String(localized: "budgets_step_hints_title")
    static let budgetsStepHintsSubtitle = String(localized: "budgets_step_hints_subtitle")
    static let budgetRowHint = String(localized: "budget_row_hint")
    static let allCategoriesUsed = String(localized: "all_categories_used")
    static let allCategoriesUsedHint = String(localized: "all_categories_used_hint")
    static let selectCategory = String(localized: "select_category")
    static let searchCategory = String(localized: "search_category")

    static func budgetsEditLimitLabel(_ amount: String) -> String {
        String(format: budgetsEditLimitLabelFormat, amount)
    }

    static func budgetsSpent(_ amount: String) -> String {
        String(format: budgetsSpentFormat, amount)
    }

    static func budgetsPerDay(_ amount: String, _ days: Int) -> String {
        String(format: budgetsPerDayFormat, amount, days)
    }

    static func budgetsPaceSlower(_ percent: Int) -> String {
        String(format: budgetsPaceSlowerFormat, percent)
    }

    static func budgetsPaceFaster(_ percent: Int) -> String {
        String(format: budgetsPaceFasterFormat, percent)
    }

    static func budgetsPaceExceededBy(_ amount: String) -> String {
        String(format: budgetsPaceExceededByFormat, amount)
    }

    static func budgetsAllocatedOf(_ allocated: String, _ limit: String) -> String {
        String(format: budgetsAllocatedOfFormat, allocated, limit)
    }

    static func budgetsAllocated(_ amount: String) -> String {
        String(format: budgetsAllocatedFormat, amount)
    }

    static func budgetsSpentOfLimit(_ spent: String, _ limit: String) -> String {
        String(format: budgetsSpentOfLimitFormat, spent, limit)
    }

    static func budgetsPercent(_ percent: Int) -> String {
        String(format: budgetsPercentFormat, percent)
    }

    static func budgetsLeftPerDay(_ remaining: String, _ perDay: String) -> String {
        String(format: budgetsLeftPerDayFormat, remaining, perDay)
    }

    static func budgetsLeftAmount(_ amount: String) -> String {
        String(format: budgetsLeftAmountFormat, amount)
    }

    static func budgetsExceededBy(_ amount: String) -> String {
        String(format: budgetsExceededByFormat, amount)
    }

    static func budgetsUnallocated(_ amount: String) -> String {
        String(format: budgetsUnallocatedFormat, amount)
    }

    static func budgetsOverAllocated(_ amount: String) -> String {
        String(format: budgetsOverAllocatedFormat, amount)
    }

    // MARK: - Statistics

    static let expenses = String(localized: "expenses")
    static let noData = String(localized: "no_data")
    static let noDataHint = String(localized: "no_data_hint")
    static let byCategories = String(localized: "by_categories")
    static let incomes = String(localized: "incomes")
    static let noDataHintIncome = String(localized: "no_data_hint_income")
    static let totalForPeriod = String(localized: "total_for_period")
    static let totalExpenses = String(localized: "total_expenses")
    static let noTransactionsForPeriod = String(localized: "no_transactions_for_period")
    static let amount = String(localized: "amount")
    static let periodDay = String(localized: "statistics_period_day")
    static let periodWeek = String(localized: "statistics_period_week")
    static let periodMonth = String(localized: "statistics_period_month")
    static let periodYear = String(localized: "statistics_period_year")
    static let periodAllTime = String(localized: "statistics_period_all_time")
    /// Пункт меню периода на главной — с «ё», как в `MainPeriodMenu.html`
    static let periodAllTimeMenu = String(localized: "period_all_time_menu")

    static func noTransactionsForPeriod(category: String) -> String {
        String(format: noTransactionsForPeriod, category)
    }

    // MARK: - Onboarding

    static let onboardingSkip = String(localized: "onboarding_skip")
    static let onboardingNext = String(localized: "onboarding_next")
    static let onboardingStart = String(localized: "onboarding_start")
    static let onboardingWelcomeTitle = String(localized: "onboarding_welcome_title")
    static let onboardingWelcomeSubtitle = String(localized: "onboarding_welcome_subtitle")
    static let onboardingTransactionsTitle = String(localized: "onboarding_transactions_title")
    static let onboardingTransactionsSubtitle = String(localized: "onboarding_transactions_subtitle")
    static let onboardingStatisticsTitle = String(localized: "onboarding_statistics_title")
    static let onboardingStatisticsSubtitle = String(localized: "onboarding_statistics_subtitle")
    static let onboardingBudgetsTitle = String(localized: "onboarding_budgets_title")
    static let onboardingBudgetsSubtitle = String(localized: "onboarding_budgets_subtitle")
    static let onboardingPagePosition = String(localized: "onboarding_page_position")

    static func onboardingPagePosition(current: Int, total: Int) -> String {
        String(format: onboardingPagePosition, current, total)
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

    static func appVersion(_ version: String) -> String {
        String(format: appVersion, version)
    }
    static let contactSupport = String(localized: "contact_support")
    static let quickActions = String(localized: "quick_actions")
    static let faq = String(localized: "faq")
    static let noAnswerFound = String(localized: "no_answer_found")
    static let supportAvailable = String(localized: "support_available")
    static let helpSupportIntro = String(localized: "help_support_intro")
    static let expandAnswer = String(localized: "expand_answer")
    static let collapseAnswer = String(localized: "collapse_answer")
    static let writeToUs = String(localized: "write_to_us")
    static let website = String(localized: "website")
    static let telegram = String(localized: "telegram")
    static let supportEmail = String(localized: "support_email")
    static let supportWebsite = String(localized: "support_website")
    static let supportTelegram = String(localized: "support_telegram")
    static let lastUpdated = String(localized: "last_updated")
    static let termsIntro = String(localized: "terms_intro")

    // MARK: - Data

    static let data = String(localized: "data")
    static let deleteAllData = String(localized: "delete_all_data")
    static let deleteAllDataConfirm = String(localized: "delete_all_data_confirm")
    static let deleteAllDataMessage = String(localized: "delete_all_data_message")

    // MARK: - Calculator

    static let calculatorDivisionByZero = String(localized: "calculator_division_by_zero")
    static let calculatorNonPositive = String(localized: "calculator_non_positive")
    static let calculatorKeyPlus = String(localized: "calculator_key_plus")
    static let calculatorKeyMinus = String(localized: "calculator_key_minus")
    static let calculatorKeyMultiply = String(localized: "calculator_key_multiply")
    static let calculatorKeyDivide = String(localized: "calculator_key_divide")
    static let calculatorKeyComma = String(localized: "calculator_key_comma")
    static let calculatorKeyBackspace = String(localized: "calculator_key_backspace")
    static let calculatorTripleZero = String(localized: "calculator_triple_zero")
    static let calculatorKeyTripleZero = String(localized: "calculator_key_triple_zero")

    // MARK: - Category Carousel

    static let carouselSearchHint = String(localized: "carousel_search_hint")
    static let carouselAllCategoriesHint = String(localized: "carousel_all_categories_hint")

    // MARK: - Tabs

    static let tabHome = String(localized: "tab_home")
    static let tabStatistics = String(localized: "tab_statistics")
    static let addTransactionLabel = String(localized: "add_transaction_label")

    // MARK: - Design System

    static let dsPreviousPeriod = String(localized: "ds_previous_period")
    static let dsNextPeriod = String(localized: "ds_next_period")
    static let dsChoosePeriodHint = String(localized: "ds_choose_period_hint")
    static let dsChooseAccountHint = String(localized: "ds_choose_account_hint")
    static let dsCurrencySign = String(localized: "ds_currency_sign")

    // MARK: - Debug

    #if DEBUG
    static let debugSection = String(localized: "debug_section")
    static let debugLoadFixture = String(localized: "debug_load_fixture")
    static let debugLoadFixtureConfirm = String(localized: "debug_load_fixture_confirm")
    static let debugLoadFixtureMessage = String(localized: "debug_load_fixture_message")
    static let load = String(localized: "load")
    static let dsCatalogTitle = String(localized: "ds_catalog_title")
    static let dsCatalogColors = String(localized: "ds_catalog_colors")
    static let dsCatalogCategoryColors = String(localized: "ds_catalog_category_colors")
    static let dsCatalogFonts = String(localized: "ds_catalog_fonts")
    static let dsCatalogStrokesAndShadows = String(localized: "ds_catalog_strokes_and_shadows")
    static let dsCatalogRadii = String(localized: "ds_catalog_radii")
    static let dsCatalogSpacing = String(localized: "ds_catalog_spacing")
    #endif

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
