//
//  AccountSelectionStore.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import Foundation

/// Общий выбранный счет для экранов, которые фильтруют данные по счету.
/// Живет на уровне RootTabView, поэтому выбор не сбрасывается при переключении вкладок
@MainActor
@Observable
final class AccountSelectionStore {

    // MARK: - Properties

    /// Выбранный счет; nil — показываются все счета
    var selectedAccount: Account?

    // MARK: - Methods

    /// Сбрасывает выбор, если счет удалили: экраны не должны обращаться к удаленной модели.
    /// Сравнение по ссылке, чтобы не читать свойства удаленного объекта
    func removeSelectionIfDeleted(from accounts: [Account]) {
        guard let selectedAccount else { return }

        if !accounts.contains(where: { $0 === selectedAccount }) {
            self.selectedAccount = nil
        }
    }
}
