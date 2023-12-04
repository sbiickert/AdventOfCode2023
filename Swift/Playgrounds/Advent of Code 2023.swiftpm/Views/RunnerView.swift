import SwiftUI

class SolutionRunner: ObservableObject {
    @Published var running: Bool = false
    @Published var result: AoCResult?
    @Published var elapsed: Int = 0
    
    @MainActor
    func asyncSolve(_ input: AoCInput) async {
        let start = Date()
        elapsed = 0
        result = input.solution.solve(input)
        running = false
        elapsed = Int(Date().timeIntervalSince(start) * 1000)
    }
}

struct RunnerView: View {
    var input: AoCInput
    @StateObject private var runner = SolutionRunner()
    
    @ViewBuilder
    var progress: some View {
        if runner.running {
            ProgressView()
        }
        else {
            EmptyView()
        }
    }
    var body: some View {
        VStack {
            Button {
                runner.running = true
                Task {
                    await runner.asyncSolve(input)
                }
            } label: {
                Text("Solve Day \(input.solution.day)")
            }
            .disabled(runner.running)
            ResultView(result:$runner.result, elapsed: $runner.elapsed)
            InputContentView(input: input)
        }
        .padding()
        .overlay(progress)
        .navigationTitle("Runner")
    }
}

@available(iOS 16.0, *)
struct RunnerView_Previews: PreviewProvider {
    static var previews: some View {
        RunnerView(input: AoCInput.inputsFor(solution: AoCSolution.solutions[0])[0])
    }
}
