import SwiftUI

struct InputContentView: View {
    var input: AoCInput
    var body: some View {
        ScrollView {
            HStack {
                LazyVStack(alignment: .leading) {
                    if (input.solution.emptyLinesIndicateMultipleInputs) {
                        ForEach(0..<AoCInput.readGroupedInputFile(named: input.fileName, atIndex: input.index).count, id: \.self) {
                            Text(AoCInput.readGroupedInputFile(named: input.fileName, atIndex: input.index)[$0])
                                .font(.custom("Menlo", fixedSize: 12))
                        }
                    }
                    else {
                        ForEach(0..<AoCInput.readInputFile(named: input.fileName, removingEmptyLines: false).count, id: \.self) {
                            Text(AoCInput.readInputFile(named: input.fileName, removingEmptyLines: false)[$0])
                                .font(.custom("Menlo", fixedSize: 12))
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct InputContentView_Previews: PreviewProvider {
    static var previews: some View {
        InputContentView(input: AoCInput.inputsFor(solution: AoCSolution.solutions[0])[0])
    }
}
