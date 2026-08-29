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
                Button(AppString.delete, role: .destructive) {
                    viewModel.confirmDeleteAllData(context: context)
                    onDataReset()
                }
            } message: {
                Text(AppString.deleteAllDataMessage)
            }
        }
    }
}

// MARK: - Subviews

private extension SettingsView {

    var generalSection: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(AppString.general, style: .sectionHeader, color: AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.xSmall)

            SettingsActionRowView(
                icon: AppImage.categoriesGrid,
                iconColor: AppColor.accent,
                title: AppString.categories
            ) {
                coordinator.show(.categories)
            }
            .cardShadow(cornerRadius: AppRadius.card)
        }
    }

    var informationSection: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(AppString.information, style: .sectionHeader, color: AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.xSmall)

            VStack(spacing: .zero) {
                SettingsActionRowView(
                    icon: AppImage.handRaised,
                    iconColor: AppColor.decorativePurple,
                    title: AppString.privacyPolicy
                ) {
                    coordinator.show(.privacyPolicy)
                }

                Divider()
                    .padding(.leading, AppSpacing.listDividerIndent)

                SettingsActionRowView(
                    icon: AppImage.questionmarkCircle,
                    iconColor: AppColor.warning,
                    title: AppString.helpAndSupport
                ) {
                    coordinator.show(.helpSupport)
                }

                Divider()
                    .padding(.leading, AppSpacing.listDividerIndent)

                SettingsActionRowView(
                    icon: AppImage.docText,
                    iconColor: AppColor.expense,
                    title: AppString.termsOfService
                ) {
                    coordinator.show(.termsOfService)
                }
            }
            .cardShadow(cornerRadius: AppRadius.card)
        }
    }

    var dataSection: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(AppString.data, style: .sectionHeader, color: AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.xSmall)

            SettingsActionRowView(
                icon: AppImage.trashFill,
                iconColor: AppColor.expense,
                title: AppString.deleteAllData,
                titleColor: AppColor.expense,
                showsChevron: false
            ) {
                viewModel.prepareDeleteAllData()
            }
            .cardShadow(cornerRadius: AppRadius.card)
        }
    }

    var appInfoSection: some View {
        VStack(spacing: AppSpacing.small) {
            AppText(AppString.appName, style: .sectionHeader, color: AppColor.textSecondary)
            AppText(AppString.appVersion, style: .caption, color: AppColor.textSecondary)
        }
        .padding(.top, AppSpacing.xLarge)
    }
}

// MARK: - Settings Row View

struct SettingsRowLabel: View {

    let icon: Image
    let iconColor: Color
    let title: String
    var titleColor: Color = AppColor.textPrimary
    var showsChevron: Bool = true

    var body: some View {
        HStack(spacing: AppSpacing.large) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                icon
                    .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .circleShadow()

            AppText(title, style: .bodySmaller, color: titleColor)

            Spacer()

            if showsChevron {
                AppImage.chevronRight
                    .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                    .foregroundStyle(AppColor.textTertiary)
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.medium)
        .contentShape(Rectangle())
    }
}

struct SettingsRowView<Destination: View>: View {

    // MARK: - Properties

    let icon: Image
    let iconColor: Color
    let title: String
    let destination: Destination

    // MARK: - Body

    var body: some View {
        NavigationLink {
            destination
        } label: {
            SettingsRowLabel(icon: icon, iconColor: iconColor, title: title)
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsActionRowView: View {

    // MARK: - Properties

    let icon: Image
    let iconColor: Color
    let title: String
    var titleColor: Color = AppColor.textPrimary
    var showsChevron: Bool = true
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            SettingsRowLabel(
                icon: icon,
                iconColor: iconColor,
                title: title,
                titleColor: titleColor,
                showsChevron: showsChevron
            )
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

/// Убирает подсветку нажатия у строк настроек: стандартный фон рисуется прямоугольником
/// и выходит за скругления карточки
struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
