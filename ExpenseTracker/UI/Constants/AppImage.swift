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
    static let chevronLeft = Image(systemName: "chevron.left")
    static let chevronRight = Image(systemName: "chevron.right")
    static let chevronDown = Image(systemName: "chevron.down")
    static let trash = Image(systemName: "trash")
    static let trashFill = Image(systemName: "trash.fill")
    static let pencil = Image(systemName: "pencil")
    static let starFill = Image(systemName: "star.fill")
    static let calendar = Image(systemName: "calendar")
    static let textAlign = Image(systemName: "text.alignleft")

    // MARK: - Dashboard

    static let emptyState = Image(systemName: "tray")
    static let noteBubble = Image(systemName: "text.bubble")
    static let incomeArrow = Image(systemName: "arrow.down.circle.fill")
    static let expenseArrow = Image(systemName: "arrow.up.circle.fill")
    static let noIcon = Image(systemName: "minus")

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
    static let folder = Image(systemName: "folder")

    // MARK: - Statistics

    static let chartPie = Image(systemName: "chart.pie")
    static let chevronLeftCircleFill = Image(systemName: "chevron.left.circle.fill")
    static let chevronRightCircleFill = Image(systemName: "chevron.right.circle.fill")

    // MARK: - Plans

    static let chartBarDoc = Image(systemName: "chart.bar.doc.horizontal")

    // MARK: - Settings

    static let helpCircle = Image(systemName: "questionmark.circle.fill")
    static let envelope = Image(systemName: "envelope.fill")
    static let globe = Image(systemName: "globe")
    static let message = Image(systemName: "message.fill")
    static let arrowUpRight = Image(systemName: "arrow.up.right")
}
