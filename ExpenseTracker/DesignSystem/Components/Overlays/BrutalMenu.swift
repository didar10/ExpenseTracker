//
//  BrutalMenu.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Пункт меню
struct BrutalMenuItem: Identifiable {

    // MARK: - Types

    enum Role {
        case normal
        /// Красный текст: «Удалить»
        case destructive
    }

    // MARK: - Properties

    let id = UUID()
    let title: String
    var icon: Image?
    var role: Role = .normal
    /// Выбранный пункт залит accent и отмечен галочкой
    var isSelected = false
    let action: () -> Void
}

extension View {

    /// Меню под (или над) View, к которой применен модификатор: строки по 50 pt,
    /// выбранная — accent. Обводка без тени, фон затемнен на 35%.
    ///
    /// `liftsSource: true` — источник рисуется поверх затемнения карточкой,
    /// как строка операции в контекстном меню
    func brutalMenu(
        isPresented: Binding<Bool>,
        items: [BrutalMenuItem],
        alignment: HorizontalAlignment = .leading,
        minWidth: CGFloat = BrutalMenuMetrics.minWidth,
        liftsSource: Bool = false
    ) -> some View {
        modifier(BrutalMenuModifier(
            isPresented: isPresented,
            items: items,
            alignment: alignment,
            minWidth: minWidth,
            liftsSource: liftsSource
        ))
    }
}

/// Размеры из `Design/html/TxContextMenu.html` и `MainPeriodMenu.html` (.menu)
enum BrutalMenuMetrics {
    static let minWidth: CGFloat = 220
    /// Меню периода уже контекстного
    static let periodMinWidth: CGFloat = 200
    /// Зазор между источником и меню
    static let gap: CGFloat = 8
    static let rowPadding: CGFloat = 16
    /// Отступ от краев экрана, если меню не помещается
    static let screenMargin: CGFloat = 20
}

// MARK: - Modifier

private struct BrutalMenuModifier: ViewModifier {

    // MARK: - Properties

    @Binding var isPresented: Bool
    let items: [BrutalMenuItem]
    let alignment: HorizontalAlignment
    let minWidth: CGFloat
    let liftsSource: Bool

    @State private var sourceFrame: CGRect = .zero

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { frame in
                sourceFrame = frame
            }
            .modifier(BrutalOverlayPresenter(isPresented: $isPresented) { dismiss in
                BrutalMenuLayout(
                    sourceFrame: sourceFrame,
                    alignment: alignment,
                    lifted: liftsSource ? AnyView(liftedSource(content)) : nil
                ) {
                    BrutalMenuList(items: items, minWidth: minWidth) { item in
                        dismiss(item.action)
                    }
                }
            })
    }

    private func liftedSource(_ content: Content) -> some View {
        content
            .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
            .brutalBorder(radius: DS.Radius.card)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

// MARK: - Layout

/// Ставит меню у источника: под ним, а если не помещается — над ним
private struct BrutalMenuLayout<Menu: View>: View {

    // MARK: - Properties

    let sourceFrame: CGRect
    let alignment: HorizontalAlignment
    let lifted: AnyView?
    @ViewBuilder let menu: Menu

    @State private var menuSize: CGSize = .zero

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                if let lifted {
                    lifted
                        .frame(width: sourceFrame.width, height: sourceFrame.height)
                        .offset(x: sourceFrame.minX, y: sourceFrame.minY)
                }

                menu
                    .fixedSize()
                    .onGeometryChange(for: CGSize.self) { $0.size } action: { menuSize = $0 }
                    .offset(menuOrigin(in: proxy))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .ignoresSafeArea()
    }

    // MARK: - Private Methods

    private func menuOrigin(in proxy: GeometryProxy) -> CGSize {
        let bounds = proxy.size
        let safeBottom = bounds.height - proxy.safeAreaInsets.bottom
        let margin = BrutalMenuMetrics.screenMargin

        let preferredX = alignment == .trailing ? sourceFrame.maxX - menuSize.width : sourceFrame.minX
        let x = min(max(preferredX, margin), bounds.width - menuSize.width - margin)

        let below = sourceFrame.maxY + BrutalMenuMetrics.gap
        let above = sourceFrame.minY - BrutalMenuMetrics.gap - menuSize.height
        let y = below + menuSize.height <= safeBottom || above < proxy.safeAreaInsets.top ? below : above

        return CGSize(width: x, height: y)
    }
}

// MARK: - List

/// Список пунктов. Отдельно от модификатора — для превью и снапшотов
struct BrutalMenuList: View {

    // MARK: - Properties

    let items: [BrutalMenuItem]
    var minWidth: CGFloat = BrutalMenuMetrics.minWidth
    let onSelect: (BrutalMenuItem) -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > .zero {
                    ListDivider()
                }

                row(item)
            }
        }
        .frame(minWidth: minWidth)
        .background(DS.Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
        .brutalBorder(radius: DS.Radius.card)
    }

    private func row(_ item: BrutalMenuItem) -> some View {
        Button {
            onSelect(item)
        } label: {
            HStack(spacing: BrutalMenuMetrics.rowPadding) {
                Text(item.title)
                    .font(DS.Font.bodyBold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if item.isSelected {
                    DS.Icon.checkmark
                        .font(.system(size: DS.Size.iconM, weight: .bold))
                        .accessibilityHidden(true)
                } else if let icon = item.icon {
                    icon
                        .font(.system(size: DS.Size.iconM, weight: .medium))
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(foreground(item))
            .padding(.horizontal, BrutalMenuMetrics.rowPadding)
            .frame(minHeight: DS.Size.menuRow)
            .background(item.isSelected ? DS.Color.accent : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(MenuRowStyle())
        .accessibilityAddTraits(item.isSelected ? .isSelected : [])
    }

    private func foreground(_ item: BrutalMenuItem) -> Color {
        if item.isSelected { return DS.Color.onAccent }
        return item.role == .destructive ? DS.Color.danger : DS.Color.ink
    }
}

/// Нажатая строка подсвечивается полупрозрачным accent — обводки у строки нет
private struct MenuRowStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(DS.Color.accent.opacity(configuration.isPressed ? Constants.pressedOpacity : .zero))
    }
}

private enum Constants {
    static let pressedOpacity: Double = 0.5
}

// MARK: - Previews

#if DEBUG
private struct BrutalMenuPreview: View {

    @State private var isPeriodMenuShown = true
    @State private var isRowMenuShown = false

    var body: some View {
        DSPreviewGallery {
            HStack {
                Spacer()
                PeriodSelector(title: "Ноябрь", isNextEnabled: false, onPrevious: {}, onNext: {}) {
                    isPeriodMenuShown = true
                }
                .brutalMenu(
                    isPresented: $isPeriodMenuShown,
                    items: [
                        BrutalMenuItem(title: "Неделя") {},
                        BrutalMenuItem(title: "Месяц", isSelected: true) {},
                        BrutalMenuItem(title: "Год") {},
                        BrutalMenuItem(title: "Всё время") {}
                    ],
                    alignment: .trailing,
                    minWidth: BrutalMenuMetrics.periodMinWidth
                )
            }

            TransactionRow(title: "Еда", subtitle: "Продукты на неделю", amount: "−4 850",
                           icon: Image(systemName: "cup.and.saucer"), color: .green)
                .onLongPressGesture { isRowMenuShown = true }
                .brutalMenu(
                    isPresented: $isRowMenuShown,
                    items: [
                        BrutalMenuItem(title: "Изменить", icon: Image(systemName: "pencil")) {},
                        BrutalMenuItem(title: "Дублировать", icon: Image(systemName: "plus.square.on.square")) {},
                        BrutalMenuItem(title: "Удалить", icon: Image(systemName: "trash"), role: .destructive) {}
                    ],
                    liftsSource: true
                )
        }
    }
}

#Preview("Меню периода · светлая") {
    BrutalMenuPreview()
}

#Preview("Меню периода · темная") {
    BrutalMenuPreview()
        .preferredColorScheme(.dark)
}

#Preview("Список: выбранный и удаление") {
    DSPreviewGallery {
        BrutalMenuList(items: [
            BrutalMenuItem(title: "Месяц", isSelected: true) {},
            BrutalMenuItem(title: "Изменить", icon: Image(systemName: "pencil")) {},
            BrutalMenuItem(title: "Удалить", icon: Image(systemName: "trash"), role: .destructive) {}
        ]) { _ in }
        .fixedSize()
    }
}
#endif
