# Макеты ExpenseTracker — мягкий брутализм

Экспорт из холста от 25.11.2026: 56 экранов.

- `screens/<Имя>.png` — картинка экрана, 2× (780 × 1688 для телефона).
- `html/<Имя>.html` — исходник того же экрана: точные цвета, отступы, радиусы, шрифты в CSS.
  Открывается в браузере (шрифты подгружаются с Google Fonts).
- Если PNG и HTML расходятся — верить HTML.
- `_Tokens`, `_Components`, `_TabBar` — справочные доски дизайн-системы.
- `CategoryCarousel-01…10` — состояния ленты категорий и листов на экране новой операции.

Холст (для людей): https://claude.ai/artifact/XYUSrMq7NjSHVS9LmQPknx
Прототип анимаций (для людей): https://claude.ai/artifact/KhQutQ8oTmKJRcAAehLSra

## Для CLAUDE.md

```markdown
## Макеты
- PNG экранов: Design/screens/<Экран>.png — ориентир по виду
- HTML экранов: Design/html/<Экран>.html — точные цвета, отступы, радиусы, шрифты
- Список экранов: Design/README.md. Если PNG и HTML расходятся, верить HTML.
- Ссылки на холст и прототип в README — для людей, агенту они недоступны.
```

## Экраны

| Файл | Экран |
| --- | --- |
| Main | Главная |
| _Tokens | Токены, шрифты, тени |
| _Components | Компоненты |
| _TabBar | Таббар — плавающая панель |
| MainDark | Главная — тёмная тема |
| Statistics | Статистика |
| Budgets | Бюджеты |
| Settings | Настройки |
| MainPeriodMenu | Главная — выбор периода |
| MainAllTime | Всё время |
| MainScrolled | История (прокрутка) |
| MainEmpty | Пусто |
| TxContextMenu | Меню операции |
| TxDeleteConfirm | Удалить операцию? |
| AddTransaction | Новый расход |
| AddIncome | Новый доход |
| EditTransaction | Редактирование |
| AccountPicker | Выбор счёта |
| DatePicker | Выбор даты |
| CategoryCarousel-01 | Лента: «Без категории» |
| CategoryCarousel-02 | Свайп → «Продукты» |
| CategoryCarousel-03 | Во время свайпа |
| CategoryCarousel-04 | Поиск в центре |
| CategoryCarousel-05 | Тап → поиск |
| CategoryCarousel-06 | Все категории |
| CategoryCarousel-07 | Выбор счёта |
| CategoryCarousel-08 | Выбор даты |
| CategoryCarousel-09 | Калькулятор: 1 200 + 800 |
| CategoryCarousel-10 | Калькулятор: деление на 0 |
| StatisticsIncome | Доходы |
| StatisticsScrolled | Прокрутка |
| StatisticsEmpty | Нет данных |
| BudgetsEmpty | Бюджеты — пусто |
| MonthlyLimit | Лимит на месяц |
| MonthlyLimitEmpty | Лимит на месяц — пусто |
| AddBudget | Новый бюджет |
| AddBudgetFilled | Новый бюджет — заполнен |
| AccountSelection | Выбор счёта |
| AccountSelectionEdit | Редактирование |
| AccountDeleteAlert | Удаление счёта |
| AccountSelectionEmpty | Нет счетов |
| AccountForm | Новый счёт |
| AccountFormEdit | Редактировать счёт |
| CategoriesManage | Расходы |
| CategoriesIncome | Доходы |
| CategoriesEdit | Управление |
| CategoriesEmpty | Пусто |
| AddCategory | Новая категория |
| AddCategoryEdit | Редактировать категорию |
| CategoryTransactions | Операции категории |
| MainTransfer | Главная — перевод в ленте |
| AddTransfer | Перевод — пусто |
| AddTransferPickTo | Перевод — выбор «Куда» |
| AddTransferFilled | Перевод — заполнен |
| AddTransferWarn | Перевод — баланс в минус |
| EditTransfer | Перевод — редактирование |
