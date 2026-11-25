//
//  AppImage.swift
//  ExpenseTracker
//
//  Created by Didar on 09.04.2026.
//

import SwiftUI

enum AppImage {

    // MARK: - Common

    static let close = Image(systemName: "xmark")
    static let plus = Image(systemName: "plus")
    static let checkmark = Image(systemName: "checkmark")
    static let checkmarkCircleFill = Image(systemName: "checkmark.circle.fill")
    static let chevronRight = Image(systemName: "chevron.right")
    static let chevronDown = Image(systemName: "chevron.down")
    static let chevronUp = Image(systemName: "chevron.up")
    static let trash = Image(systemName: "trash")
    static let tabHome = Image(systemName: "house")
    static let tabStatistics = Image(systemName: "chart.bar")
    static let tabBudgets = Image(systemName: "target")
    static let tabSettings = Image(systemName: "gearshape")
    static let trashFill = Image(systemName: "trash.fill")
    #if DEBUG
    static let loadFixture = Image(systemName: "arrow.triangle.2.circlepath")
    static let designSystemCatalog = Image(systemName: "paintpalette.fill")
    #endif
    static let pencil = Image(systemName: "pencil")
    static let starFill = Image(systemName: "star.fill")
    static let calendar = Image(systemName: "calendar")
    static let textAlign = Image(systemName: "text.alignleft")

    // MARK: - Dashboard

    static let noteBubble = Image(systemName: "text.bubble")
    static let incomeArrow = Image(systemName: "arrow.down.circle.fill")
    static let repeatAction = Image(systemName: "arrow.clockwise")
    static let duplicate = Image(systemName: "plus.square.on.square")
    static let limitTarget = Image(systemName: "target")
    /// Операция дохода без категории
    static let incomeFallback = Image(systemName: "banknote")
    static let undo = Image(systemName: "arrow.uturn.backward")
    static let dailyLimit = Image(systemName: "gauge.with.needle")
    static let dataUnavailable = Image(systemName: "externaldrive.badge.exclamationmark")

    // MARK: - Transactions

    static let expenseDirection = Image(systemName: "arrow.up.right")
    static let incomeDirection = Image(systemName: "arrow.down.left")
    static let deleteBackward = Image(systemName: "delete.backward.fill")

    // MARK: - Accounts

    static let allAccounts = Image(systemName: "square.stack.3d.up.fill")
    static let creditcard = Image(systemName: "creditcard")
    static let noAccountsIcon = Image(systemName: "creditcard.and.123")
    static let plusCircleFill = Image(systemName: "plus.circle.fill")

    // MARK: - Categories

    static let categoriesGrid = Image(systemName: "square.grid.2x2")
    static let ellipsis = Image(systemName: "ellipsis")
    static let folder = Image(systemName: "folder")

    // MARK: - Statistics

    static let chartPie = Image(systemName: "chart.pie")
    static let chevronLeftCircleFill = Image(systemName: "chevron.left.circle.fill")
    static let chevronRightCircleFill = Image(systemName: "chevron.right.circle.fill")

    // MARK: - Plans


    // MARK: - Onboarding

    static let onboardingWelcome = Image(systemName: "wallet.bifold.fill")
    static let onboardingTransactions = Image(systemName: "plus.circle.fill")
    static let onboardingStatistics = Image(systemName: "chart.pie.fill")
    static let onboardingBudgets = Image(systemName: "target")

    // MARK: - Settings

    static let helpCircle = Image(systemName: "questionmark.circle.fill")
    static let questionmarkCircle = Image(systemName: "questionmark.circle")
    static let envelope = Image(systemName: "envelope.fill")
    static let globe = Image(systemName: "globe")
    static let message = Image(systemName: "message.fill")
    static let arrowUpRight = Image(systemName: "arrow.up.right")
    static let handRaised = Image(systemName: "hand.raised.fill")
    static let docText = Image(systemName: "doc.text")
    static let dollarsignCircle = Image(systemName: "dollarsign.circle")
}
