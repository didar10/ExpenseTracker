import SwiftUI

/// Подтверждение, удаление и отмена удаления для лент операций.
@MainActor
@Observable
final class TransactionDeletionState {
    private(set) var transactionPendingDeletion: Transaction?
    var showingDeleteConfirmation = false
    var showingSaveError = false
    private(set) var undoAction: TransactionUndoAction?
    private var undoDismissTask: Task<Void, Never>?

    /// Удаляет без вопросов — подтверждение уже получено в алерте; тост «Отменить» страхует от ошибки
    func deleteTransaction(_ transaction: Transaction, using repository: TransactionRepository) {
        let draft = TransactionDraft(transaction)

        perform {
            try repository.delete(transaction)
        } onSuccess: {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            showUndo(TransactionUndoAction(draft: draft))
        }
    }

    func requestDeletion(of transaction: Transaction) {
        transactionPendingDeletion = transaction
        showingDeleteConfirmation = true
    }

    /// Текст алерта для операции, ожидающей удаления
    var deletionMessage: String? {
        transactionPendingDeletion.map(TransactionDeletionMessage.text(for:))
    }

    func confirmDeletion(using repository: TransactionRepository) {
        guard let transaction = transactionPendingDeletion else { return }

        transactionPendingDeletion = nil
        deleteTransaction(transaction, using: repository)
    }

    func cancelDeletion() {
        transactionPendingDeletion = nil
    }

    func undoLastAction(using repository: TransactionRepository) {
        guard let undoAction else { return }

        perform {
            try repository.add(undoAction.draft)
        } onSuccess: {
            dismissUndo()
        }
    }

    func dismissUndo() {
        undoDismissTask?.cancel()
        undoDismissTask = nil

        withAnimation(Self.animation(DS.Motion.overlay)) {
            undoAction = nil
        }
    }

    // MARK: - Private Methods

    /// Новое действие заменяет тост предыдущего: отменить можно только последнее
    private func showUndo(_ action: TransactionUndoAction) {
        undoDismissTask?.cancel()

        withAnimation(Self.animation(DS.Motion.overlay)) {
            undoAction = action
        }

        undoDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Constants.undoVisibleSeconds))
            guard !Task.isCancelled else { return }
            self?.dismissUndo()
        }
    }

    /// Изменение списка анимируется; при ошибке тост не показывается, а экран сообщает о ней
    private func perform(_ change: () throws -> Void, onSuccess: () -> Void) {
        do {
            try withAnimation(Self.animation(DS.Motion.overlay)) {
                try change()
            }
            onSuccess()
        } catch {
            showingSaveError = true
        }
    }

    private static func animation(_ animation: Animation) -> Animation? {
        UIAccessibility.isReduceMotionEnabled ? nil : animation
    }

    private enum Constants {
        static let undoVisibleSeconds = 4
    }
}
