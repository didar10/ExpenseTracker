//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftUI
import SwiftData

struct DashboardView: View {

    @Query(sort: \Expense.date, order: .reverse)
    private var expenses: [Expense]

    @State private var isAddPresented = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(expenses) { expense in
                        ExpenseRowView(expense: expense)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Расходы")

                addButton
            }
            .sheet(isPresented: $isAddPresented) {
                NavigationStack {
                    AddExpenseView()
                }
            }
        }
    }
}

private extension DashboardView {

    var addButton: some View {
        Button {
            isAddPresented = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.green)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding()
    }
}
