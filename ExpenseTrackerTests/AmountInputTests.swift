//
//  AmountInputTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import Testing
@testable import ExpenseTracker

@MainActor
struct AmountInputTests {

    // MARK: - Helpers

    private func type(_ keys: String, into input: inout AmountInput) {
        for character in keys {
            input.apply(character == "." ? .decimal : .number(String(character)))
        }
    }

    // MARK: - Tests

    @Test func groupsThousandsWhileTyping() {
        var input = AmountInput()
        type("1350000", into: &input)

        #expect(input.display == "1\u{00A0}350\u{00A0}000")
        #expect(input.value == 1_350_000)
    }

    @Test func emptyInputShowsZeroPlaceholder() {
        let input = AmountInput()

        #expect(input.display == "0")
        #expect(input.hasInput == false)
        #expect(input.isPositive == false)
    }

    @Test func limitsFractionToTwoDigitsAndIntegerToTwelve() {
        var input = AmountInput()
        type("12.345", into: &input)
        #expect(input.raw == "12.34")

        var long = AmountInput()
        type("1234567890123", into: &long)
        #expect(long.raw == "123456789012")
    }

    @Test func startsFromSavedValue() {
        #expect(AmountInput(Decimal(300_000)).display == "300\u{00A0}000")
        #expect(AmountInput(Decimal?.none).hasInput == false)
    }

    // MARK: - Обычное поле ввода

    @Test func typedTextIsGroupedLikeTransactionAmount() {
        let input = AmountInput(typedText: "500000", previous: AmountInput())

        #expect(input.display == "500\u{00A0}000")
        #expect(input.display == AmountInput("500000").display)
    }

    @Test func typedTextAcceptsCommaAndDropsExtraSymbols() {
        #expect(AmountInput(typedText: "1 500,755", previous: AmountInput()).raw == "1500.75")
        #expect(AmountInput(typedText: "007", previous: AmountInput()).raw == "7")
        #expect(AmountInput(typedText: ",5", previous: AmountInput()).raw == "0.5")
        #expect(AmountInput(typedText: "12.3.4", previous: AmountInput()).raw == "12.34")
    }

    @Test func deletingGroupSeparatorRemovesDigitBeforeIt() {
        let previous = AmountInput("500000")
        // Курсор стоял сразу после пробела в «500 000» — стерт пробел
        let input = AmountInput(typedText: "500000", previous: previous)

        #expect(input.raw == "50000")
        #expect(input.display == "50\u{00A0}000")
    }

    @Test func monthlyLimitFieldShowsGroupedAmountAndSaves() {
        let store = MonthlyLimitStore(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard)
        let viewModel = MonthlyLimitViewModel(limitStore: store)

        #expect(viewModel.amount.hasInput == false)

        viewModel.updateAmount(AmountInput(typedText: "300000", previous: viewModel.amount))

        #expect(viewModel.amount.display == "300\u{00A0}000")
        #expect(viewModel.canSave)

        viewModel.save()
        #expect(store.limit == 300_000)
    }
}
