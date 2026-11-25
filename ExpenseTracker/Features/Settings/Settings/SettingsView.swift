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

    @Environment(\.repositories) private var repositories

    /// Вызывается после удаления всех данных — нужен для возврата на главный экран
    private let onDataReset: () -> Void

    @State private var viewModel: SettingsViewModel
    @State private var coordinator: SettingsCoordinator

    // MARK: - Init

    @MainActor
    init(
        limitStore: MonthlyLimitStore,
        coordinator: SettingsCoordinator? = nil,
        onDataReset: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: SettingsViewModel(limitStore: limitStore))
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
                        #if DEBUG
                        debugSection
                        #endif
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
            .saveErrorAlert(isPresented: $viewModel.showingSaveError)
            .alert(AppString.deleteAllDataConfirm, isPresented: $viewModel.showingDeleteAllDataAlert) {
                Button(AppString.cancel, role: .cancel) {
                    viewModel.cancelDeleteAllData()
                }
                Button(AppString.delete, role: .destructive, action: handleDeleteAllData)
            } message: {
                Text(AppString.deleteAllDataMessage)
            }
            #if DEBUG
            .alert(AppString.debugLoadFixtureConfirm, isPresented: $viewModel.showingLoadFixtureAlert) {
                Button(AppString.cancel, role: .cancel) {}
                Button(AppString.load, role: .destructive, action: handleLoadFixture)
            } message: {
                Text(AppString.debugLoadFixtureMessage)
            }
            #endif
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

            SettingsRowDivider()

            SettingsToggleRowView(
                icon: AppImage.dailyLimit,
                iconColor: AppColor.income,
                title: AppString.showLimitOnDashboard,
                isOn: $viewModel.isLimitShownOnDashboard
            )
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

    #if DEBUG
    var debugSection: some View {
        SettingsSectionView(title: AppString.debugSection) {
            SettingsRowView(
                icon: AppImage.designSystemCatalog,
                iconColor: AppColor.accent,
                title: AppString.dsCatalogTitle
            ) {
                coordinator.show(.designSystemCatalog)
            }

            SettingsRowDivider()

            SettingsRowView(
                icon: AppImage.loadFixture,
                iconColor: AppColor.warning,
                title: AppString.debugLoadFixture,
                showsChevron: false
            ) {
                viewModel.prepareLoadFixture()
            }
        }
    }
    #endif

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
        guard viewModel.confirmDeleteAllData(using: repositories.appData) else { return }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onDataReset()
    }

    #if DEBUG
    func handleLoadFixture() {
        let fixture = Fixture.sample
        guard viewModel.confirmLoadFixture(fixture, using: repositories.appData) else { return }

        // Общий сброс обнуляет лимит и возвращает на главный экран — лимит фикстуры ставится после него
        onDataReset()
        viewModel.applyFixtureLimit(fixture)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    #endif
}

#Preview {
    let fixture = FixtureEnvironment(.sample)

    SettingsView(limitStore: fixture.limitStore)
        .fixture(fixture)
}
