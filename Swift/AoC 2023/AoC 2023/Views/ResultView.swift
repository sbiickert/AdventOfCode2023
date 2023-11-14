//
//  ResultView.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-05-04.
//

import SwiftUI

struct ResultView: View {
	@Binding var result: AoCResult?
	@Binding var elapsed: Int // Milliseconds since start

	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				Text("Part One").bold()
				HStack {
					Image(systemName: result?.part1 != nil ? "checkmark.seal" : "questionmark.diamond")
						.resizable(capInsets: EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
						.foregroundColor(result?.part1 != nil ? Color.green : Color.gray)
						.padding(.all, 5.0)
						.frame(width: 32, height: 32, alignment: .center)
					Text(result?.part1 ?? "No answer")
						.textSelection(.enabled)
				}
				Divider()
				Text("Part Two").bold()
				HStack {
					Image(systemName: result?.part2 != nil ? "checkmark.seal" : "questionmark.diamond")
						.resizable(capInsets: EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
						.foregroundColor(result?.part2 != nil ? Color.green : Color.gray)
						.padding(.all, 5.0)
						.frame(width: 32, height: 32, alignment: .center)
					Text(result?.part2 ?? "No answer")
						.textSelection(.enabled)
				}
			}
			StopwatchView(progressTime: $elapsed)
		}
	}
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
		ResultView(result: .constant(nil), elapsed: .constant(120))
    }
}
