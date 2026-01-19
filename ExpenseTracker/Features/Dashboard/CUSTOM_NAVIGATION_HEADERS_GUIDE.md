//
//  CUSTOM_NAVIGATION_HEADERS_GUIDE.md
//  ExpenseTracker
//
//  Created by Didar on 18.01.2026.
//

# Custom Navigation Headers - Complete Guide

This guide explains how to replace default `navigationTitle` with custom header options.

## 📋 What Changed

### Before (Default Navigation)
```swift
.navigationTitle("Главная")
.navigationBarTitleDisplayMode(.large)
```

### After (Custom Headers)
```swift
.navigationBarHidden(true)
// + Custom header in ScrollView content
```

---

## 🎯 Available Options

### Option 1: Simple Custom Header (Currently Implemented)

**File:** `CustomNavigationHeader.swift`

**Usage:**
```swift
CustomNavigationHeader(
    title: "Главная",
    subtitle: "Управление финансами",
    trailingButton: HeaderButton(
        icon: "person.crop.circle.fill",
        action: { /* your action */ }
    )
)
```

**Features:**
- ✅ Clean, simple design
- ✅ Optional subtitle
- ✅ Optional trailing button
- ✅ Scrolls with content
- ✅ Easy to customize

**Best for:** Most use cases, simple and effective

---

### Option 2: Scroll-Aware Header (Advanced)

**File:** `ScrollAwareNavigationHeader.swift` + `ScrollOffsetPreferenceKey.swift`

**Usage:**
```swift
@State private var scrollOffset: CGFloat = 0

// In body:
ScrollView {
    VStack {
        ScrollAwareNavigationHeader(
            title: "Главная",
            subtitle: "Управление финансами",
            scrollOffset: scrollOffset,
            trailingButton: HeaderButton(...)
        )
        
        // Your content
        VStack {
            // ...
        }
        .trackScrollOffset(in: "scroll", offset: $scrollOffset)
    }
}
.coordinateSpace(name: "scroll")
```

**Features:**
- ✅ Shrinks as you scroll
- ✅ Smooth animations
- ✅ Subtitle fades out
- ✅ Icons shrink
- ✅ Modern, dynamic feel

**Best for:** When you want iOS Mail/Messages-style headers

**See:** `ScrollAwareDashboardExample.swift` for full implementation

---

### Option 3: Sticky Header with Blur (iOS Style)

**Implementation:**
```swift
ZStack(alignment: .top) {
    ScrollView {
        VStack(spacing: 20) {
            // Add padding for header
            Color.clear.frame(height: 80)
            
            // Your content
            balanceCard
            transactionsList
        }
    }
    
    // Sticky header with blur
    VStack(spacing: 0) {
        CustomNavigationHeader(
            title: "Главная",
            subtitle: "Управление финансами"
        )
        
        Divider()
    }
    .background(.ultraThinMaterial)
}
```

**Features:**
- ✅ Always visible at top
- ✅ Blur background
- ✅ iOS Settings app style
- ✅ Content scrolls beneath

**Best for:** When header must always be visible

---

### Option 4: Animated Header on Appear

**Implementation:**
```swift
@State private var showHeader = false

var customHeader: some View {
    CustomNavigationHeader(...)
        .offset(y: showHeader ? 0 : -100)
        .opacity(showHeader ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showHeader = true
            }
        }
}
```

**Features:**
- ✅ Slides in from top
- ✅ Fade-in animation
- ✅ Delightful entrance

**Best for:** First screen user sees, welcome screens

---

## 🎨 Customization Examples

### Change Colors
```swift
CustomNavigationHeader(
    title: "Главная",
    subtitle: "Управление финансами",
    trailingButton: HeaderButton(
        icon: "person.crop.circle.fill",
        color: .blue, // ← Custom color
        action: { }
    )
)
```

### No Subtitle
```swift
CustomNavigationHeader(
    title: "Главная"
    // No subtitle parameter = no subtitle shown
)
```

### No Button
```swift
CustomNavigationHeader(
    title: "Главная",
    subtitle: "Управление финансами"
    // No trailingButton = no button shown
)
```

### Multiple Buttons
Create a custom header variation:
```swift
struct MultiButtonHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 34, weight: .bold))
            
            Spacer()
            
            // Multiple buttons
            HStack(spacing: 12) {
                Button { } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                }
                
                Button { } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 28))
                }
            }
        }
        .padding()
    }
}
```

---

## 📝 Current Implementation

### DashboardView
- ✅ Uses `CustomNavigationHeader`
- ✅ Title: "Главная"
- ✅ Subtitle: "Управление финансами"
- ✅ Button: Profile icon
- ✅ Scrolls with content

### StatisticsView
- ✅ Uses `CustomNavigationHeader`
- ✅ Title: "Статистика"
- ✅ Subtitle: "Анализ расходов"
- ✅ Button: Export icon
- ✅ Scrolls with content

---

## 🔧 How to Switch Between Options

### To Use Scroll-Aware Header:

1. Replace `DashboardView.swift` body with content from `ScrollAwareDashboardExample.swift`
2. Add `@State private var scrollOffset: CGFloat = 0`
3. Wrap content with `.trackScrollOffset()`
4. Use `ScrollAwareNavigationHeader` instead of `CustomNavigationHeader`

### To Use Sticky Header:

1. Wrap ScrollView content in ZStack
2. Add padding at top of ScrollView
3. Overlay header with `.ultraThinMaterial` background
4. Remove header from ScrollView content

---

## 🎯 Benefits of Custom Headers

### vs Default NavigationTitle:

1. **More Control**
   - Custom spacing, padding, alignment
   - Add any UI elements
   - Custom animations

2. **Better Design**
   - Matches your app's style
   - Consistent with card-based UI
   - More modern appearance

3. **Enhanced UX**
   - Scroll-aware behavior
   - Interactive elements
   - Better visual hierarchy

4. **Flexibility**
   - Different styles per screen
   - Easy to modify
   - Reusable components

---

## 💡 Best Practices

1. **Keep it Simple**
   - Don't overcrowd the header
   - Max 1-2 buttons
   - Clear, concise titles

2. **Consistent Design**
   - Use same header style across app
   - Consistent colors (green theme)
   - Same icon style (SF Symbols filled)

3. **Performance**
   - Avoid heavy animations
   - Use `.contentTransition()` for text
   - Keep scroll calculations lightweight

4. **Accessibility**
   - Ensure touch targets ≥ 44pt
   - Use semantic colors
   - Support Dynamic Type

---

## 🚀 Quick Reference

### Simple Header
```swift
CustomNavigationHeader(title: "Title", subtitle: "Subtitle")
```

### With Button
```swift
CustomNavigationHeader(
    title: "Title",
    trailingButton: HeaderButton(icon: "icon.name") { }
)
```

### Scroll-Aware
```swift
ScrollAwareNavigationHeader(
    title: "Title",
    scrollOffset: scrollOffset
)
```

### Hide Navigation Bar
```swift
.navigationBarHidden(true)
```

---

## 📚 Files Reference

- `CustomNavigationHeader.swift` - Simple & scroll-aware headers
- `ScrollOffsetPreferenceKey.swift` - Scroll tracking helper
- `ScrollAwareDashboardExample.swift` - Full example implementation
- `DashboardView.swift` - Currently using simple header
- `StatisticsView.swift` - Currently using simple header

---

## 🎨 Design Tokens

### Typography
- Title: `.system(size: 34, weight: .bold)`
- Subtitle: `.system(size: 15, weight: .medium)`

### Colors
- Title: `.primary`
- Subtitle: `.secondary`
- Button: `.green` (theme color)

### Spacing
- Horizontal padding: `16pt`
- Top padding: `8pt`
- Bottom padding: `4pt`
- Title-Subtitle gap: `4pt`

### Icons
- Size: `36pt`
- Style: `.hierarchical`
- Prefer: `.fill` variants

---

**Need help? All examples are fully documented with comments!**
