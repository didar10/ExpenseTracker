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
    
    // Редактируемый счет (если nil, то создаем новый)
    let account: Account?
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "creditcard.fill"
    @State private var selectedColor: String = "blue"
    @State private var initialBalance: String = ""
    @State private var isDefault: Bool = false
    
    init(account: Account? = nil) {
        self.account = account
    }
    
    var isEditMode: Bool {
        account != nil
    }
    
    var isValid: Bool {
        !name.isEmpty
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        case "indigo": return .indigo
        case "brown": return .brown
        case "cyan": return .cyan
        case "mint": return .mint
        default: return .blue
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Превью карточки счета
                        accountPreviewCard
                        
                        // Форма
                        formContent
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditMode ? "Редактировать счет" : "Новый счет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Сохранить" : "Создать") {
                        saveAccount()
                    }
                    .disabled(!isValid)
                    .bold()
                }
            }
            .onAppear {
                if let account = account {
                    // Заполняем форму для редактирования
                    name = account.name
                    selectedIcon = account.icon
                    selectedColor = account.color
                    initialBalance = account.initialBalance == 0 ? "" : "\(account.initialBalance)"
                    isDefault = account.isDefault
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var accountPreviewCard: some View {
        HStack(spacing: 16) {
            // Иконка
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(colorFromString(selectedColor).opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: selectedIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(colorFromString(selectedColor))
            }
            
            // Информация
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    AppText(name.isEmpty ? "Название счета" : name, style: .section)
                        .color(name.isEmpty ? .secondary : .primary)
                    
                    if isDefault {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.yellow)
                    }
                }
                
                if let balance = Decimal(string: initialBalance.replacingOccurrences(of: ",", with: ".")), balance > 0 {
                    AppText(balance.formatted(.currency(code: "KZT")), style: .body)
                        .color(.secondary)
                } else {
                    AppText("Начальный баланс", style: .caption)
                        .color(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        }
    }
    
    private var formContent: some View {
        VStack(spacing: 16) {
            // Название
            FormSection(title: "Название") {
                TextField("Например: Основной счет", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom("SFProDisplay-Regular", size: 16))
            }
            
            // Начальный баланс
            FormSection(title: "Начальный баланс (опционально)") {
                TextField("0", text: $initialBalance)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .font(.custom("SFProDisplay-Regular", size: 16))
            }
            
            // Иконка
            FormSection(title: "Иконка") {
                IconPickerView(selectedIcon: $selectedIcon)
            }
            
            // Цвет
            FormSection(title: "Цвет") {
                ColorPickerView(selectedColor: $selectedColor)
            }
            
            // По умолчанию
            FormSection(title: "") {
                Toggle(isOn: $isDefault) {
                    VStack(alignment: .leading, spacing: 2) {
                        AppText("Счет по умолчанию", style: .body)
                            .color(.primary)
                        AppText("Будет выбран автоматически при создании транзакций", style: .caption)
                            .color(.secondary)
                    }
                }
                .tint(.blue)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveAccount() {
        let balanceDecimal = Decimal(string: initialBalance.replacingOccurrences(of: ",", with: ".")) ?? 0
        
        if let account = account {
            // Редактирование существующего счета
            account.name = name
            account.icon = selectedIcon
            account.color = selectedColor
            account.initialBalance = balanceDecimal
            
            // Если делаем этот счет по умолчанию, снимаем флаг с других
            if isDefault {
                for acc in accounts where acc.id != account.id {
                    acc.isDefault = false
                }
            }
            account.isDefault = isDefault
        } else {
            // Создание нового счета
            let newAccount = Account(
                name: name,
                icon: selectedIcon,
                color: selectedColor,
                initialBalance: balanceDecimal,
                isDefault: isDefault
            )
            
            // Если делаем этот счет по умолчанию, снимаем флаг с других
            if isDefault {
                for acc in accounts {
                    acc.isDefault = false
                }
            }
            
            modelContext.insert(newAccount)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Form Section

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                AppText(title, style: .caption)
                    .color(.secondary)
                    .padding(.horizontal, 4)
            }
            
            VStack(spacing: 0) {
                content
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            }
        }
    }
}

// MARK: - Icon Picker

struct IconPickerView: View {
    @Binding var selectedIcon: String
    
    private let icons = [
        "creditcard.fill",
        "wallet.pass.fill",
        "banknote.fill",
        "dollarsign.circle.fill",
        "tengesign.circle.fill",
        "building.columns.fill",
        "chart.line.uptrend.xyaxis",
        "briefcase.fill",
        "bag.fill",
        "cart.fill",
        "giftcard.fill",
        "handbag.fill"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color(uiColor: .secondarySystemBackground))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundStyle(selectedIcon == icon ? .blue : .secondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Color Picker

struct ColorPickerView: View {
    @Binding var selectedColor: String
    
    private struct ColorOption: Identifiable {
        let id: String
        let name: String
        let color: Color
        
        init(_ name: String, _ color: Color) {
            self.id = name
            self.name = name
            self.color = color
        }
    }
    
    private let colors: [ColorOption] = [
        ColorOption("blue", .blue),
        ColorOption("green", .green),
        ColorOption("orange", .orange),
        ColorOption("red", .red),
        ColorOption("purple", .purple),
        ColorOption("pink", .pink),
        ColorOption("yellow", .yellow),
        ColorOption("teal", .teal),
        ColorOption("indigo", .indigo),
        ColorOption("brown", .brown),
        ColorOption("cyan", .cyan),
        ColorOption("mint", .mint)
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colors) { colorOption in
                    colorButton(for: colorOption)
                }
            }
        }
    }
    
    private func colorButton(for colorOption: ColorOption) -> some View {
        Button {
            selectedColor = colorOption.name
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            ZStack {
                Circle()
                    .fill(colorOption.color)
                    .frame(width: 44, height: 44)
                
                if selectedColor == colorOption.name {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    AccountFormView()
        .modelContainer(for: [Account.self], inMemory: true)
}
