# Code Style — ExpenseTracker

При написании и изменении кода в этом проекте строго придерживайся следующих правил:

---

## Архитектура: MVVM

- Каждый экран (Feature) состоит из **View**, **ViewModel** и при необходимости **Models**.
- **View** — только отображение UI (SwiftUI). Никакой бизнес-логики.
- **ViewModel** — класс с `@MainActor`, `ObservableObject`. Содержит всю логику, состояние экрана, обработку действий.
- **Model** — структуры данных (`SwiftData` модели, DTO, вспомогательные модели).
- View обращается к ViewModel через `@StateObject` или `@ObservedObject`, никогда напрямую к данным.

### Структура папок Feature

```
Features/
  FeatureName/
    View/
      FeatureNameView.swift
    ViewModel/
      FeatureNameViewModel.swift
    Models/
      SomeModel.swift
    Components/
      SomeSubView.swift
```

---

## Dependency Injection

- Все зависимости (сервисы, репозитории, контекст данных) передаются через **инициализатор** или **Environment**.
- ViewModel **не должен** создавать зависимости внутри себя — они инжектируются снаружи.
- Для SwiftData `ModelContext` — передавать через `@Environment(\.modelContext)` во View и прокидывать в ViewModel через метод или инициализатор.
- Избегай синглтонов. Если нужен общий сервис — передавай его через DI.

```swift
// Правильно
final class SomeViewModel: ObservableObject {
    private let repository: TransactionRepository
    
    init(repository: TransactionRepository) {
        self.repository = repository
    }
}

// Неправильно
final class SomeViewModel: ObservableObject {
    private let repository = TransactionRepository()
}
```

---

## Ресурсы: изображения и цвета

- Все изображения хранятся в **Assets.xcassets**.
- Все цвета определяются в **Assets.xcassets** как Color Set.
- Доступ к изображениям и цветам — **только через константы**, никогда через строковые литералы в коде View.

### Константы изображений

```swift
enum AppImage {
    static let dashboard = Image("dashboard")
    static let settings = Image(systemName: "gearshape.fill")
    // ...
}
```

### Константы цветов

```swift
enum AppColor {
    static let background = Color("appBackground")
    static let cardBackground = Color("cardBackground")
    static let primary = Color("primaryColor")
    static let textPrimary = Color("textPrimary")
    static let textSecondary = Color("textSecondary")
    // ...
}
```

### Использование

```swift
// Правильно
Text("Hello").foregroundColor(AppColor.textPrimary)
AppImage.settings

// Неправильно
Text("Hello").foregroundColor(Color("textPrimary"))
Image(systemName: "gearshape.fill")
```

---

## Локализация: все тексты в ресурсах

- Все строки UI хранятся в **Localizable.strings** (или String Catalog).
- Доступ к строкам — **только через константы**, никогда через строковые литералы в View.

### Константы строк

```swift
enum AppString {
    static let dashboardTitle = String(localized: "dashboard_title")
    static let totalBalance = String(localized: "total_balance")
    static let save = String(localized: "save")
    static let cancel = String(localized: "cancel")
    // ...
}
```

### Использование

```swift
// Правильно
Text(AppString.dashboardTitle)

// Неправильно
Text("Dashboard")
Text("Общий баланс")
```

---

## Организация кода в файле

- Используй `// MARK: -` для разделения секций.
- Стандартный порядок секций в файле:

```swift
// MARK: - Properties
// MARK: - Computed Properties
// MARK: - Init
// MARK: - Body (для View)
// MARK: - Actions
// MARK: - Private Methods
```

- Приватные subview выноси в `private extension`:

```swift
// MARK: - Subviews
private extension SomeView {
    var headerSection: some View { ... }
    var contentSection: some View { ... }
}
```

---

## Именование

- **Типы** (struct, class, enum, protocol): `PascalCase`
- **Переменные, функции, свойства**: `camelCase`
- **Константы**: `camelCase` (не `UPPER_SNAKE_CASE`)
- **View файлы**: `FeatureNameView.swift`
- **ViewModel файлы**: `FeatureNameViewModel.swift`
- **Bool переменные**: с префиксом `is`, `has`, `should` — `isLoading`, `hasError`, `shouldRefresh`

---

## Общие правила

- Используй SwiftUI, не UIKit (UIKit допустим только для haptic feedback и подобного).
- Шрифты — только через `AppFont` / `Font.app(.style)`.
- `@MainActor` на всех ViewModel.
- `final class` для всех ViewModel.
- Избегай force unwrap (`!`) — используй `guard let` или `if let`.
- Избегай магических чисел — выноси в константы или именованные переменные.

---

Перед написанием или изменением кода, проверь соответствие этим правилам. Если существующий код нарушает правила — приведи его в соответствие при внесении изменений в этот файл.
