//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: AddTransactionViewModel

    @Query(sort: \Category.name)
    private var categories: [Category]

    // 🔹 Только для UI (анимация / hover)
    @State private var highlightedCategory: Category?

    init(transaction: Transaction? = nil) {
        _viewModel = StateObject(
            wrappedValue: AddTransactionViewModel(transaction: transaction)
        )
    }

    var body: some View {
        VStack(spacing: 16) {

            header
            typePicker
            amountView

            if viewModel.type == .expense {
                categoriesScroll
            }

            details

            Spacer(minLength: 8)

            NumericKeypadView(
                isEnterEnabled: viewModel.isSaveEnabled,
                onKeyTap: viewModel.handleKeyTap,
                onEnterTap: {
                    viewModel.save(using: modelContext)
                    dismiss()
                }
            )
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

private extension AddTransactionView {

    var header: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
    }
}

private extension AddTransactionView {

    var typePicker: some View {
        Picker("Тип", selection: $viewModel.type) {
            Text("Расход").tag(TransactionType.expense)
            Text("Доход").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
    }
}

private extension AddTransactionView {

    var amountView: some View {
        Text(viewModel.amount.isEmpty ? "0" : viewModel.amount)
            .font(.system(size: 42, weight: .bold))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
    }
}

private extension AddTransactionView {

    var categoriesScroll: some View {
        GeometryReader { geo in
            let sidePadding = (geo.size.width - Constants.categoryItemWidth) / 2

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories) { category in
                            categoryItem(category)
                                .id(category.id)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()

                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        highlightedCategory = category
                                        viewModel.selectedCategory = category
                                        proxy.scrollTo(category.id, anchor: .center)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, sidePadding) // 🔥 ключевая строка
                }
                .onAppear {
                    if let selected = viewModel.selectedCategory {
                        DispatchQueue.main.async {
                            proxy.scrollTo(selected.id, anchor: .center)
                            highlightedCategory = selected
                        }
                    }
                }
            }
        }
        .frame(height: 96)
    }


    
    func categoryItem(_ category: Category) -> some View {
        let isSelected = viewModel.selectedCategory?.id == category.id

        return ZStack {
            VStack(spacing: 6) {

                ZStack {
                    Circle()
                        .fill(isSelected ? Color.green : Color(.secondarySystemBackground))
                        .frame(
                            width: isSelected ? Constants.selectedSize : Constants.baseSize,
                            height: isSelected ? Constants.selectedSize : Constants.baseSize
                        )

                    Image(systemName: category.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primary)
                }
            }
        }
        .frame(width: Constants.selectedSize, height: Constants.itemHeight) // 🔥 фиксированный контейнер
        .overlay(alignment: .bottom) {
            if isSelected {
                Text(category.name)
                    .font(.app(.caption))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .offset(y: 2)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }



}

private extension AddTransactionView {

    func updateCenteredCategory(midX: CGFloat, category: Category) {
        let screenMidX = UIScreen.main.bounds.midX
        let threshold: CGFloat = 24

        if abs(midX - screenMidX) < threshold {
            if highlightedCategory?.id != category.id {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    highlightedCategory = category
                    viewModel.selectedCategory = category
                }
            }
        }
    }
}



private extension AddTransactionView {

    var details: some View {
        VStack(spacing: 12) {
            DatePicker("Дата", selection: $viewModel.date, displayedComponents: .date)

            TextField("Комментарий", text: $viewModel.note)
                .textFieldStyle(.roundedBorder)
        }
    }
}

private enum Constants {
    static let categoryItemWidth: CGFloat = 60
    static let baseSize: CGFloat = 44
    static let selectedSize: CGFloat = 54
    static let itemHeight: CGFloat = 78
}
