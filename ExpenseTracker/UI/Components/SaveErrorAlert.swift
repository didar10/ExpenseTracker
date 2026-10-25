//
//  SaveErrorAlert.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

extension View {

    /// Общее сообщение о том, что изменения не записались на диск
    func saveErrorAlert(isPresented: Binding<Bool>) -> some View {
        alert(AppString.saveFailedTitle, isPresented: isPresented) {
            Button(AppString.ok, role: .cancel) {}
        } message: {
            Text(AppString.saveFailedMessage)
        }
    }
}
