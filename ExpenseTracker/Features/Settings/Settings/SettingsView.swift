import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query private var accounts: [Account]
    @Query private var categories: [Category]
    @Environment(\.repositories) private var repositories

    private let onDataReset: () -> Void

    @State private var viewModel: SettingsViewModel
    @State private var coordinator: SettingsCoordinator
    #if DEBUG
    @State private var showingDebugMenu = false
    #endif

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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                Text(AppString.settings)
                    .font(DS.Font.screenTitle)
                    .foregroundStyle(DS.Color.ink)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: DS.Settings.sectionSpacing) {
                    generalSection
                    informationSection
                    dataSection
                }
                .padding(.top, DS.Settings.sectionSpacing)

                appInfoSection
                    .padding(.top, DS.Settings.footerTop)
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.xs)
            .padding(.bottom, DS.Spacing.lg)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .background(DS.Color.bg)
        .sheet(item: $coordinator.activeRoute) { route in
            SettingsRouteView(route: route)
        }
        .brutalAlert(
            isPresented: $viewModel.showingDeleteAllDataAlert,
            title: AppString.deleteAllDataConfirm,
            message: AppString.deleteAllDataMessage,
            confirmTitle: AppString.delete,
            onConfirm: handleDeleteAllData,
            onCancel: viewModel.cancelDeleteAllData
        )
        .saveErrorAlert(isPresented: $viewModel.showingSaveError)
        #if DEBUG
        .brutalAlert(
            isPresented: $viewModel.showingLoadFixtureAlert,
            title: AppString.debugLoadFixtureConfirm,
            message: AppString.debugLoadFixtureMessage,
            confirmTitle: AppString.load,
            onConfirm: handleLoadFixture
        )
        #endif
    }

    private var generalSection: some View {
        SettingsSectionView(title: AppString.general) {
            SettingsRowView(
                icon: Image(systemName: "wallet.bifold"),
                iconColor: DS.CategoryColor.green.color,
                title: AppString.accounts,
                value: accounts.count.formatted()
            ) {
                coordinator.show(.accounts)
            }
            ListDivider()

            SettingsRowView(
                icon: Image(systemName: "tag"),
                iconColor: DS.CategoryColor.orange.color,
                title: AppString.categories,
                value: categories.count.formatted()
            ) {
                coordinator.show(.categories)
            }
            ListDivider()

            HStack(spacing: DS.Spacing.md) {
                SettingsIconBadge(icon: Image(systemName: "target"), fill: DS.Color.accent, foreground: DS.Color.onAccent)
                BrutalToggle(
                    AppString.showLimitOnDashboard,
                    subtitle: AppString.settingsLimitSubtitle,
                    isOn: $viewModel.isLimitShownOnDashboard
                )
            }
            .settingsRowInsets()
        }
    }

    private var informationSection: some View {
        SettingsSectionView(title: AppString.information) {
            SettingsRowView(icon: Image(systemName: "shield"), title: AppString.privacyPolicy) {
                coordinator.show(.privacyPolicy)
            }
            ListDivider()

            SettingsRowView(icon: AppImage.questionmarkCircle, title: AppString.helpAndSupport) {
                coordinator.show(.helpSupport)
            }
            ListDivider()

            SettingsRowView(icon: AppImage.docText, title: AppString.termsOfService) {
                coordinator.show(.termsOfService)
            }
        }
    }

    private var dataSection: some View {
        SettingsSectionView(title: AppString.data) {
            SettingsRowView(
                icon: DS.Icon.trash,
                iconColor: DS.Color.accountRed,
                title: AppString.deleteAllData,
                subtitle: AppString.settingsDeleteDataSubtitle,
                isDestructive: true,
                action: viewModel.prepareDeleteAllData
            )
        }
    }

    private var appInfoSection: some View {
        VStack(spacing: DS.Settings.subtitleSpacing) {
            Text(AppString.appName)
                .font(DS.Font.appName)
                .foregroundStyle(DS.Color.ink)
            versionLabel
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var versionLabel: some View {
        let label = Text(viewModel.appVersionTitle)
            .font(DS.Font.moneySmall)
            .foregroundStyle(DS.Color.ink2)

        #if DEBUG
        label
            .contentShape(Rectangle())
            .onLongPressGesture { showingDebugMenu = true }
            .accessibilityAction(named: AppString.debugSection) { showingDebugMenu = true }
            .brutalMenu(isPresented: $showingDebugMenu, items: [
                BrutalMenuItem(title: AppString.deleteAllData, icon: DS.Icon.trash, role: .destructive, action: viewModel.prepareDeleteAllData),
                BrutalMenuItem(title: AppString.debugLoadFixture, icon: AppImage.loadFixture, action: viewModel.prepareLoadFixture),
                BrutalMenuItem(title: AppString.dsCatalogTitle, icon: AppImage.designSystemCatalog) {
                    coordinator.show(.designSystemCatalog)
                }
            ], alignment: .center)
        #else
        label
        #endif
    }

    private func handleDeleteAllData() {
        guard viewModel.confirmDeleteAllData(using: repositories.appData) else { return }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onDataReset()
    }

    #if DEBUG
    private func handleLoadFixture() {
        let fixture = Fixture.sample
        guard viewModel.confirmLoadFixture(fixture, using: repositories.appData) else { return }

        // Общий сброс обнуляет лимит, поэтому ставим лимит фикстуры после него.
        onDataReset()
        viewModel.applyFixtureLimit(fixture)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    #endif
}

#if DEBUG
private struct SettingsPreview: View {
    var fixture: Fixture

    var body: some View {
        let environment = FixtureEnvironment(fixture)
        return SettingsView(limitStore: environment.limitStore)
            .fixture(environment)
    }
}

#Preview("Светлая") { SettingsPreview(fixture: .sample) }
#Preview("Тёмная") { SettingsPreview(fixture: .sample).preferredColorScheme(.dark) }
#Preview("Пустая база") { SettingsPreview(fixture: .empty) }
#Preview("Пустая база · тёмная") { SettingsPreview(fixture: .empty).preferredColorScheme(.dark) }
#endif
