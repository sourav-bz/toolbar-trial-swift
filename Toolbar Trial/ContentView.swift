//
// ScrollHeaderToolbar.swift
// Author: Mark Battistella
// Website: https://markbattistella.com
//
//
// Purpose:
// This SwiftUI implementation provides a dynamic navigation interface where a large navigation
// title, along with additional UI elements like buttons, transitions into a smaller inline
// navigation title as the user scrolls. This mimics the behaviour found in Apple’s first-party
// apps like Journal or Store, but without an official API to achieve this directly. The custom
// `AppSettings` class and views work together to detect scrolling and trigger the title resizing
// and toolbar adjustments.
//

import SwiftUI

/// Main view struct responsible for creating the layout and passing down app settings
struct ContentView: View {
    
    /// Stores the settings for the app, including scroll detection
    private var appSettings: AppSettings = .init()
    
    /// The title displayed in the navigation bar and header
    private let title: String = "Journal"
    
    var body: some View {
        GeometryReader { outer in
            NavigationStack {
                ListView(
                    title: title,
                    outer: outer,
                    appSettings: appSettings
                )
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        ToolbarTitle(
                            title: title,
                            appSettings: appSettings
                        )
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

/// ListView struct that creates a list and includes a custom header
struct ListView: View {
    
    /// The title for the list header
    let title: String
    
    /// Geometry proxy to provide size and positioning information
    let outer: GeometryProxy
    
    /// App settings passed down to detect scroll and control state
    let appSettings: AppSettings
    
    var body: some View {
        List {
            Section {
                ForEach(1..<30, id: \.self) { Text("Index: \($0)") }
            } header: {
                HeaderView(
                    title: title,
                    outer: outer,
                    appSettings: appSettings
                )
            }
        }
    }
}

/// HeaderView struct to display the large title and additional header buttons
struct HeaderView: View {
    
    /// The title displayed in the header
    let title: String
    
    /// Geometry proxy used to detect scroll and size
    let outer: GeometryProxy
    
    /// App settings that manage scroll detection and toolbar visibility
    let appSettings: AppSettings
    
    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .textCase(nil)
            
            Spacer()
            
            HeaderButtons()
        }
        .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
        .foregroundStyle(.primary)
        .background {
            appSettings.scrollDetector(topInsets: outer.safeAreaInsets.top)
        }
    }
}

/// A set of header buttons typically used for actions like search or more options
struct HeaderButtons: View {
    
    let items = ["magnifyingglass", "ellipsis"]
    
    var body: some View {
        Group {
            ForEach(items, id: \.self) { item in
                Button {
                    // Do something here...
                } label: {
                    Image(systemName: item)
                        .frame(width: 18, height: 18)
                        .padding(4)
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
        }
    }
}

/// ToolbarTitle struct responsible for displaying the smaller, inline toolbar title when scrolled
struct ToolbarTitle: View {
    
    /// The title displayed in the toolbar
    let title: String
    
    /// App settings to control when the title should appear based on scroll position
    let appSettings: AppSettings
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
            .opacity(appSettings.showingScrolledTitle ? 1 : 0)
            .animation(.easeInOut, value: appSettings.showingScrolledTitle)
    }
}

/// Observable class to track app settings like scroll state and toolbar visibility
@Observable
final class AppSettings {
    
    /// A Boolean indicating whether the toolbar title should be shown when scrolled
    var showingScrolledTitle = false
    
    /// Scroll detector method that tracks the scroll position and adjusts the
    /// `showingScrolledTitle` value
    ///
    /// - Parameter topInsets: The safe area top inset, used to determine scroll position
    /// relative to the toolbar
    /// - Returns: A GeometryReader that updates the `showingScrolledTitle` based on scroll position
    func scrollDetector(topInsets: CGFloat) -> some View {
        GeometryReader { proxy in
            
            // Calculate the position of the header in global coordinates
            let minY = proxy.frame(in: .global).minY
            
            // Detect if the header is scrolled under the toolbar
            let isUnderToolbar = minY - topInsets < 0
            
            // Update `showingScrolledTitle` when the header is scrolled
            Color.clear.onChange(of: isUnderToolbar) { _, newVal in
                self.showingScrolledTitle = newVal
            }
        }
    }
}