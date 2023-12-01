import SwiftUI

struct ContentView: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SolutionList()
        } content: {
            EmptyView()
        } detail: {
            EmptyView()
        }
        .navigationSplitViewStyle(.balanced)
    }
}
