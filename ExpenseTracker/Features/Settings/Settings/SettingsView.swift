//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var context

    /// Вызывается после удаления всех данных — нужен для возврата на главный экран
    private let onDataReset: () -> Void

    @State private var viewModel = SettingsViewModel()
    @State private var coordinator: SettingsCoordinator

    // MARK: - Init

    @MainActor
    init(
        coordinator: SettingsCoordinator? = nil,
        onDataReset: @escaping () -> Void = {}
    ) {
        _coordinator = State(initialValue: coordinator ?? SettingsCoordinator())
        self.onDataReset = onDataReset
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
                ScreenHeaderView(title: AppString.settings)

                ScrollView {
                    VStack(spacing: AppSpacing.xLarge) {
                        generalSection
                        informationSection
                        dataSection
                        appInfoSection
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.tabBarBottomInset)
                }
            }
            .background(AppColor.background)
            .navigationBarHidden(true)
            .sheet(item: $coordinator.activeRoute) { route in
                SettingsRouteView(route: route)
            }
            .alert(AppString.deleteAllDataConfirm, isPresented: $viewModel.showingDeleteAllDataAlert) {
                Button(AppString.cancel, role: .cancel) {
                    viewModel.cancelDeleteAllData()
                }
                Button(AppString.delete, role: .destructive, action: handleDeleteAllData)
            } message: {
                Text(AppString.deleteAllDataMessage)
            }
        }
    }
}

// MARK: - Subviews

private extension SettingsView {

    var generalSection: some View {
        SettingsSectionView(title: AppString.general) {
            SettingsRowView(
                icon: AppImage.categoriesGrid,
                iconColor: AppColor.accent,
                title: AppString.categories
            ) {
                coordinator.show(.categories)
            }
        }
    }

    var informationSection: some View {
        SettingsSectionView(title: AppString.information) {
            SettingsRowView(
                icon: AppImage.handRaised,
                iconColor: AppColor.decorativePurple,
                title: AppString.privacyPolicy
            ) {
                coordinator.show(.privacyPolicy)
            }

            SettingsRowDivider()

            SettingsRowView(
                icon: AppImage.questionmarkCircle,
                iconColor: AppColor.warning,
                title: AppString.helpAndSupport
            ) {
                coordinator.show(.helpSupport)
            }

            SettingsRowDivider()

            SettingsRowView(
                icon: AppImage.docText,
                // Красный в приложении означает расход и удаление, поэтому
                // у обычного пункта меню он не используется
                iconColor: AppColor.accent,
                title: AppString.termsOfService
            ) {
                coordinator.show(.termsOfService)
            }
        }
    }

    var dataSection: some View {
        SettingsSectionView(title: AppString.data) {
            SettingsRowView(
                icon: AppImage.trashFill,
                iconColor: AppColor.expense,
                title: AppString.deleteAllData,
                titleColor: AppColor.expense,
                showsChevron: false
            ) {
                viewModel.prepareDeleteAllData()
            }
        }
    }

    var appInfoSection: some View {
        VStack(spacing: AppSpacing.small) {
            AppText(AppString.appName, style: .sectionHeader, color: AppColor.textSecondary)

            AppText(viewModel.appVersionTitle, style: .caption, color: AppColor.textSecondary)
        }
        .padding(.top, AppSpacing.xLarge)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Actions

private extension SettingsView {

    func handleDeleteAllData() {
        viewModel.confirmDeleteAllData(context: context)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onDataReset()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self, BudgetPlan.self], inMemory: true)
}
