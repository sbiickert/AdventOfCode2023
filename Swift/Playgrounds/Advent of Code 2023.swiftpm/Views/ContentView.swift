import SwiftUI

@available(iOS 16.0, *)
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

//        VStack {
//            Button("Run") {
//                let s = AoCSolution.solutions[0]
//                let i = AoCInput(solution: s, fileName: AoCInput.fileName(day: 1, isTest: false), index: 0)
//                let r = s.solve(i)
//                print(r)
//            }
//        }
    }
}
