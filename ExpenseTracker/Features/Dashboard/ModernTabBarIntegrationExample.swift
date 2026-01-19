//
//  ModernTabBarIntegrationExample.swift
//  ExpenseTracker
//
//  Example showing how to integrate scroll-aware tab bar in your views
//

import SwiftUI

// MARK: - Example 1: Simple View (No Scroll)
struct SimpleViewExample: View {
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    var body: some View {
        VStack {
            Text("Simple View")
            Text("Tab bar always visible")
        }
        // No scroll tracking needed - tab bar stays visible
    }
}

// MARK: - Example 2: Scrollable View (Auto Hide/Show)
struct ScrollableViewExample: View {
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Your content here
                    ForEach(0..<50) { index in
                        Text("Item \(index)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
                .padding(.bottom, 100) // ⚠️ Important: Space for tab bar
                .trackScrollOffset(
                    in: "scrollExample",
                    offset: $scrollOffset,
                    tabBarVisible: isTabBarVisible
                )
            }
            .coordinateSpace(name: "scrollExample")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Example 3: List View
struct ListViewExample: View {
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    let items = Array(0..<100)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("Item \(item)")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .padding(.bottom, 100) // Space for tab bar
                .trackScrollOffset(
                    in: "listScroll",
                    offset: $scrollOffset,
                    tabBarVisible: isTabBarVisible
                )
            }
            .coordinateSpace(name: "listScroll")
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Example 4: Grid View
struct GridViewExample: View {
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<50) { index in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.gradient)
                            .frame(height: 150)
                            .overlay {
                                Text("\(index)")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .padding()
                .padding(.bottom, 100) // Space for tab bar
                .trackScrollOffset(
                    in: "gridScroll",
                    offset: $scrollOffset,
                    tabBarVisible: isTabBarVisible
                )
            }
            .coordinateSpace(name: "gridScroll")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Example 5: Complex View with Custom Header
struct ComplexViewExample: View {
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Custom header that shrinks on scroll
                    headerView
                        .opacity(scrollOffset < 100 ? 1 : 0.5)
                        .scaleEffect(scrollOffset < 100 ? 1 : 0.9)
                    
                    // Main content
                    contentSection
                }
                .trackScrollOffset(
                    in: "complexScroll",
                    offset: $scrollOffset,
                    tabBarVisible: isTabBarVisible
                )
            }
            .coordinateSpace(name: "complexScroll")
            .navigationBarHidden(true)
        }
    }
    
    var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.purple.gradient)
            
            Text("Complex View")
                .font(.largeTitle.bold())
            
            Text("Header shrinks on scroll")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.systemBackground))
    }
    
    var contentSection: some View {
        VStack(spacing: 20) {
            ForEach(0..<30) { index in
                cardView(index: index)
            }
        }
        .padding()
        .padding(.bottom, 100) // Space for tab bar
        .background(Color(.systemGroupedBackground))
    }
    
    func cardView(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.blue)
                Text("Card \(index)")
                    .font(.headline)
                Spacer()
                Text("\(index * 10)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: Double(index) / 30.0)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

// MARK: - Example 6: View Without Auto-Hide (Manual Control)
struct ManualControlExample: View {
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    var body: some View {
        NavigationStack {
            VStack {
                // Manual controls
                HStack {
                    Button("Hide Tab Bar") {
                        withAnimation {
                            isTabBarVisible.wrappedValue = false
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Show Tab Bar") {
                        withAnimation {
                            isTabBarVisible.wrappedValue = true
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<30) { index in
                            Text("Item \(index)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                    // Using simple tracking without auto-hide
                    .trackScrollOffset(in: "manualScroll", offset: $scrollOffset)
                }
                .coordinateSpace(name: "manualScroll")
                
                // Show current offset
                Text("Scroll Offset: \(Int(scrollOffset))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Quick Integration Template

/*
 
 ✨ QUICK START TEMPLATE ✨
 
 Copy this template to quickly add scroll-aware tab bar to any view:
 
 ```swift
 struct YourView: View {
     // 1. Add these properties
     @State private var scrollOffset: CGFloat = 0
     @Environment(\.tabBarVisibility) private var isTabBarVisible
     
     var body: some View {
         NavigationStack {
             // 2. Wrap in ScrollView with coordinateSpace
             ScrollView {
                 VStack {
                     // Your content here
                 }
                 .padding(.bottom, 100)  // 3. Add bottom padding
                 // 4. Add tracking modifier
                 .trackScrollOffset(
                     in: "yourViewScroll",  // Use unique name
                     offset: $scrollOffset,
                     tabBarVisible: isTabBarVisible
                 )
             }
             .coordinateSpace(name: "yourViewScroll")  // 5. Match name here
         }
     }
 }
 ```
 
 */

// MARK: - Customization Examples

extension View {
    /// Custom scroll behavior - only hide after scrolling past a specific point
    func customScrollBehavior(threshold: CGFloat = 200) -> some View {
        // This is just an example - you would implement this in ScrollOffsetModifier
        self
    }
    
    /// Always keep tab bar visible (disable auto-hide)
    func alwaysShowTabBar() -> some View {
        self.environment(\.tabBarVisibility, .constant(true))
    }
}

// MARK: - Usage Notes

/*
 
 📝 KEY POINTS TO REMEMBER:
 
 1. **Coordinate Space**
    - Each ScrollView needs a unique coordinate space name
    - Name must match in both .coordinateSpace() and .trackScrollOffset()
 
 2. **Bottom Padding**
    - Always add .padding(.bottom, 100) to scroll content
    - Prevents content from being hidden behind tab bar
 
 3. **Environment Value**
    - @Environment(\.tabBarVisibility) gives access to tab bar state
    - It's a Binding, so changes update in real-time
 
 4. **Two Tracking Modes**
    - With tabBarVisible: Auto hide/show behavior
    - Without tabBarVisible: Just tracks offset, no auto-hide
 
 5. **Performance**
    - Only one PreferenceKey per ScrollView
    - Threshold prevents excessive updates
    - Lazy loading recommended for large lists
 
 */
