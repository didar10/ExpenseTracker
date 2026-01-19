//
//  ScrollOffsetPreferenceKey.swift
//  ExpenseTracker
//
//  Created by Didar on 18.01.2026.
//

import SwiftUI

/// PreferenceKey to track scroll offset for scroll-aware UI elements
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// ViewModifier to track scroll position with tab bar visibility control
struct ScrollOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding var offset: CGFloat
    @Binding var isTabBarVisible: Bool
    
    @State private var lastOffset: CGFloat = 0
    @State private var scrollDirection: ScrollDirection = .idle
    
    enum ScrollDirection {
        case up, down, idle
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: -geo.frame(in: .named(coordinateSpace)).origin.y
                        )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let delta = value - lastOffset
                
                // Update offset
                offset = value
                
                // Determine scroll direction and tab bar visibility
                if abs(delta) > 5 { // Threshold to avoid jitter
                    if delta > 0 {
                        // Scrolling down - hide tab bar
                        scrollDirection = .down
                        if offset > 100 { // Only hide after scrolling past header
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isTabBarVisible = false
                            }
                        }
                    } else if delta < 0 {
                        // Scrolling up - show tab bar
                        scrollDirection = .up
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isTabBarVisible = true
                        }
                    }
                }
                
                // Show tab bar when near top
                if offset < 20 {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isTabBarVisible = true
                    }
                }
                
                lastOffset = value
            }
    }
}

/// Simplified scroll tracking without tab bar control
struct SimpleScrollOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding var offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: -geo.frame(in: .named(coordinateSpace)).origin.y
                        )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                offset = value
            }
    }
}

extension View {
    /// Track scroll offset for this view
    func trackScrollOffset(in coordinateSpace: String, offset: Binding<CGFloat>) -> some View {
        modifier(SimpleScrollOffsetModifier(coordinateSpace: coordinateSpace, offset: offset))
    }
    
    /// Track scroll offset with automatic tab bar visibility control
    func trackScrollOffset(
        in coordinateSpace: String,
        offset: Binding<CGFloat>,
        tabBarVisible: Binding<Bool>
    ) -> some View {
        modifier(ScrollOffsetModifier(
            coordinateSpace: coordinateSpace,
            offset: offset,
            isTabBarVisible: tabBarVisible
        ))
    }
}
