import Foundation

class Day17: AoCSolution {
	override init() {
		super.init()
		self.day = 17
		self.name = "Clumsy Crucible"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let city = Day17.parseCity(input: input.textLines)
		//        grid.draw()
		let part1 = solvePartOne(in: city)
		
		return AoCResult(part1: "\(part1)", part2: "world")
	}
	
	static var lowestToDate = Int.max / 2 // Big number
	static var MEMO = Dictionary<CityBlock,Int>()
	
	func solvePartOne(in city: CityState) -> Int {
		Day17.MEMO = Dictionary<CityBlock,Int>()
		let start = AoCCoord2D.origin
		let b = city.getBlock(start)
		let modCity = city.changed(start, val: CityBlock(pos: AoCPos2D(location: start, direction: nil),
														 streak: 0,
														 heatLoss: b.heatLoss,
														 cost: 0))
//		modCity.draw()
//		return 0
		let leastHeatLoss = visitNeighbors(from: start, in: modCity) // 1351, 1110, 1097 too high  798 wrong  838?? 797
		return leastHeatLoss
	}
	
	func visitNeighbors(from coord: AoCCoord2D, in city: CityState) -> Int {
		// Default: coords to left, right and straight ahead.
		// Don't enter a CityBlock where shouldVisit == false.
		// Can't go ahead if the visit direction of the CityBlock 1,2,3 back
		// are the same as the current block's visit direction
		if coord == city.end {
			Day17.lowestToDate = min(Day17.lowestToDate, city.accumulatedHeatLoss)
			//city.draw()
			print(Day17.lowestToDate)
			return city.accumulatedHeatLoss
		}
		var lowestHeatLoss = Int.max
		
		let currentBlock = city.getBlock(coord)
		if Day17.MEMO.keys.contains(currentBlock) {
			return Day17.MEMO[currentBlock]!
		}
//		let md = coord.manhattanDistance(to: city.end)
//		let guessToComplete: Int
//		//if md > 30 { guessToComplete = (md+3) * 4 }
//		//if md > 20 { guessToComplete = md * 4 }
//		//if md > 10 { guessToComplete = md * 3 }
//		if md > 8 { guessToComplete = md * 2 }
//		else { guessToComplete = md }
		let guessToComplete = 1
		if currentBlock.cost + guessToComplete >= Day17.lowestToDate {
			return city.accumulatedHeatLoss
		}

		let ahead = currentBlock.pos.direction ?? .east // <-- only nil on the start block
		let left = AoCTurn.left.apply(to: ahead)
		let right = AoCTurn.right.apply(to: ahead)
		//let back = AoCTurn.left.apply(to: ahead, size: .oneEighty)
		
		let aheadCoord = coord.offset(direction: ahead)
		let leftCoord = coord.offset(direction: left)
		let rightCoord = coord.offset(direction: right)
		//let oneBackCoord = coord.offset(direction: back)
		//let twoBackCoord = oneBackCoord.offset(direction: back)

		let leftBlock = city.getBlock(leftCoord)
		let rightBlock = city.getBlock(rightCoord)
		//let oneBackBlock = city.getBlock(oneBackCoord)
		//let twoBackBlock = city.getBlock(twoBackCoord)
		
		let streak = currentBlock.streak + 1
		if streak <= 3 {
			let aheadBlock = city.getBlock(aheadCoord)
			if aheadBlock.shouldVisit(cost: currentBlock.cost) {
				let modCity = city.changed(aheadCoord, val: aheadBlock.visited(cost: currentBlock.cost, direction: ahead, streak: streak))
				let result = visitNeighbors(from: aheadCoord, in: modCity)
				lowestHeatLoss = min(result,lowestHeatLoss)
			}
		}

		if leftBlock.shouldVisit(cost: currentBlock.cost) {
			let modCity = city.changed(leftCoord, val: leftBlock.visited(cost: currentBlock.cost, direction: left, streak: 1))
			let result = visitNeighbors(from: leftCoord, in: modCity)
			lowestHeatLoss = min(result,lowestHeatLoss)
		}
		
		if rightBlock.shouldVisit(cost: currentBlock.cost) {
			let modCity = city.changed(rightCoord, val: rightBlock.visited(cost: currentBlock.cost, direction: right, streak: 1))
			let result = visitNeighbors(from: rightCoord, in: modCity)
			lowestHeatLoss = min(result,lowestHeatLoss)
		}
		Day17.MEMO[currentBlock] = lowestHeatLoss

		return lowestHeatLoss
	}
	
	static func parseCity(input: [String]) -> CityState {
		var grid = [[CityBlock]]()
		for row in 0..<input.count {
			grid.append([CityBlock]())
			for col in 0..<input[row].count {
				let block = CityBlock(pos: AoCPos2D(location: AoCCoord2D(x: col, y: row), direction: nil),
									  streak: 0,
									  heatLoss: Int(String(input[row][col]))!,
									  cost: Int.max)
				grid[row].append(block)
			}
		}
		return CityState(state: grid)
	}
}

struct CityBlock: AoCGridRenderable, Hashable {
	let pos: AoCPos2D
	let streak: Int
	let heatLoss: Int
	let cost: Int
	
	var canVisit: Bool { heatLoss > 0 }
	
	var glyph: String {
		if pos.direction == nil {
			return " \(heatLoss) "
		}
		return "\(String(format: "%03d", cost))"
	}
	
	func shouldVisit(cost: Int) -> Bool {
		return canVisit && (self.cost > cost + heatLoss)
	}
	
	func visited(cost: Int, direction dir: AoCDir, streak str: Int) -> CityBlock {
		assert(str<4)
		let newPos = AoCPos2D(location: pos.location, direction: dir)
		return CityBlock(pos: newPos, streak: str, heatLoss: heatLoss, cost: cost + heatLoss)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(pos)
		hasher.combine(streak)
	}
}

struct CityState: CustomDebugStringConvertible {
	let state: [[CityBlock]]
	var size: Int { state.count-1 }
	var accumulatedHeatLoss: Int {
		return state[size][size].cost
	}
	var end: AoCCoord2D {
		return AoCCoord2D(x: size, y: size)
	}
	func getBlock(_ coord: AoCCoord2D) -> CityBlock { return getBlock(row: coord.row, col: coord.col) }
	func getBlock(row: Int, col: Int) -> CityBlock {
		if row < 0 || col < 0 || row > size || col > size {
			return CityBlock(pos: AoCPos2D(location: AoCCoord2D(x: col, y: row), direction: nil), streak: 0, heatLoss: 0, cost: 0)
		}
		return state[row][col]
	}
	func changed(_ coord: AoCCoord2D, val: CityBlock) -> CityState {
		return changed(row: coord.row, col: coord.col, val: val)
	}
	func changed(row: Int, col: Int, val: CityBlock) -> CityState {
		if row < 0 || col < 0 || row > size || col > size {
			return self // No change
		}
		var mutableState = state
		mutableState[row][col] = val
		return CityState(state: mutableState)
	}
	var debugDescription: String {
		var str = ""
		for row in 0...size {
			let rowStr = state[row].map({$0.glyph}).joined(separator: " ")
			str += rowStr + "\n"
		}
		return str
	}
	func draw() {
		print("Accumulated: \(accumulatedHeatLoss)")
		print("\(self)\n")
	}
}
