//
//  AccountFormView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI
import SwiftData

struct AccountFormView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Account.name) private var accounts: [Account]
    
    @StateObject private var viewModel: AccountFormViewModel
    
    @State private var showingDeleteAlert = false
    
    init(account: Account? = nil) {
        _viewModel = StateObject(wrappedValue: AccountFormViewModel(account: account))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Превью карточки счета
                        accountPreviewCard
                        
                        // Форма
                        formContent
                    }
                    .padding()
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .shadow(
                                    color: .black.opacity(0.1),
                                    radius: 3,
                                    x: 0,
                                    y: 2
                                )
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.save(accounts: accounts, using: modelContext)
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(viewModel.isValid ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 40, height: 40)
                                .shadow(
                                    color: .black.opacity(viewModel.isValid ? 0.1 : 0.05),
                                    radius: 3,
                                    x: 0,
                                    y: 2
                                )
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(viewModel.isValid ? .black : .gray)
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Удалить счет?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    viewModel.delete(using: modelContext)
                    dismiss()
                }
            } message: {
                Text("Счет и все его транзакции будут удалены. Это действие нельзя отменить.")
            }
        }
    }
    
    // MARK: - Views
    
    private var accountPreviewCard: some View {
        HStack(spacing: 12) {
            // Иконка
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(named: viewModel.selectedColor).opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: viewModel.selectedIcon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(named: viewModel.selectedColor))
            }
            
            // Информация
            HStack {
                TextField("Название счета", text: $viewModel.name)
                    .font(.custom("SFProDisplay-Semibold", size: 16))
                    .foregroundStyle(viewModel.name.isEmpty ? .secondary : .primary)
                
                if viewModel.isDefault {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.yellow)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .card(cornerRadius: 16)
    }
    
    private var formContent: some View {
        VStack(spacing: 16) {
            // Начальный баланс
            FormSection(title: "Начальный баланс (опционально)") {
                TextField("0", text: $viewModel.initialBalance)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .font(.custom("SFProDisplay-Regular", size: 16))
            }
            
            // Иконка
            FormSection(title: "Иконка") {
                IconPickerView(selectedIcon: $viewModel.selectedIcon, onSelect: viewModel.selectIcon)
            }
            
            // Цвет
            FormSection(title: "Цвет") {
                ColorPickerView(selectedColor: $viewModel.selectedColor, onSelect: viewModel.selectColor)
            }
            
            // По умолчанию
            FormSection(title: "") {
                Toggle(isOn: $viewModel.isDefault) {
                    VStack(alignment: .leading, spacing: 2) {
                        AppText("Счет по умолчанию", style: .body)
                            .color(.primary)
                        AppText("Будет выбран автоматически при создании транзакций", style: .caption)
                            .color(.secondary)
                    }
                }
                .tint(.blue)
            }
            
            // Кнопка удаления (только в режиме редактирования)
            if viewModel.isEditMode {
                Button {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 15, weight: .semibold))
                            
                            Text("Удалить счет")
                                .font(.custom("SFProDisplay-Semibold", size: 16))
                        }
                        .foregroundStyle(.red)
                        
                        Spacer()
                    }
                    .padding(16)
                    .cardShadow(cornerRadius: 12)
                }
            }
        }
    }
}

#Preview {
    AccountFormView()
        .modelContainer(for: [Account.self], inMemory: true)
}
