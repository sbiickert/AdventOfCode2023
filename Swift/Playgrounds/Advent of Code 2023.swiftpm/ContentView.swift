import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Run") {
                let s = AoCSolution.solutions[0]
                let i = AoCInput(solution: s, fileName: AoCInput.fileName(day: 1, isTest: false), index: 0)
                let r = s.solve(i)
                print(r)
            }
        }
    }
}
