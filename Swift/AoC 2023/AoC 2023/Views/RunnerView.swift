//
//  ResultView.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-27.
//

import SwiftUI
import SpriteKit
import OSLog

class SolutionRunner: ObservableObject {
	@Published var running: Bool = false
	@Published var result: AoCResult?
	@Published var elapsed: Int = 0
	
	@MainActor
	func asyncSolve(_ input: AoCInput, visualize: Bool) async {
		let start = Date()
		elapsed = 0
		input.solution.visualizationEnabled = visualize
		result = await input.solution.solve(input)
		running = false
		elapsed = Int(Date().timeIntervalSince(start) * 1000)
	}
}

struct RunnerView: View {
	@StateObject private var runner = SolutionRunner()
	@State private var willVisualize = false
	var input: AoCInput
	var scene: SKScene {
			let scene = VisualizerScene()
			scene.size = CGSize(width: 500, height: 400)
			scene.scaleMode = .aspectFit
			scene.view?.ignoresSiblingOrder = true
			return scene
		}


	@ViewBuilder
	var progress: some View {
		if runner.running {
			if willVisualize {
				SpriteView(scene: scene)
			}
			else {
				ProgressView()
			}
		}
		else {
			EmptyView()
		}
	}
	
	var body: some View {
		VStack {
			InputContentView(input: input)
			Button {
				runner.running = true
				Task {
					await runner.asyncSolve(input, visualize: willVisualize)
				}
			} label: {
				Text("Solve Day \(input.solution.day)")
			}
			.disabled(runner.running)
			Toggle(isOn: $willVisualize) {
				Text("Visualizer")
			}
			
			ResultView(result:$runner.result, elapsed: $runner.elapsed)
		}
		.padding()
		.overlay(progress)
		.navigationTitle("Runner")
   }
}

struct RunnerView_Previews: PreviewProvider {
	static var previews: some View {
		RunnerView(input: AoCInput.inputsFor(solution: AoCSolution.solutions[0])[0])
	}
}



