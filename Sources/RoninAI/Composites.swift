//
//  File.swift
//  
//
//  Created by leerie simpson on 10/4/21.
//

import Foundation
import GameplayKit


@resultBuilder
public struct CompositeBehaviorResultBuilder {
	
	public static func buildExpression(_ expression: Behavior) -> [Behavior] {
		[expression]
	}
	
	public static func buildBlock(_ components: Behavior...) -> [Behavior] {
		return components
	}
}


/// Composite nodes are nodes that contain 0 or more childnodes. 
public class CompositeBehavior: Behavior {
	
	public var runner: Behavior!
	
	public override init(name: String, category: Category) {
		super.init(name: name, category: category)
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		runner = coder.decodeObject(of: Behavior.self, forKey: "runner")
	}
	
	public override func encode(with coder: NSCoder) {
		super.encode(with: coder)
		coder.encode(runner, forKey: "runner")
	}
	
	public override func reset() {
		super.reset()
		children?.forEach{ $0.reset() }
		state = .ready
	}
	
	public func handleRunner(runner: Behavior) {
		self.runner = runner
	}
	
	public func add(behavior: Behavior) {
		children?.append(behavior)
		behavior.parent = self
	}
	
	public func remove(behavior: Behavior) {
		children?.removeAll(where: { $0.id == behavior.id })
		behavior.parent = nil
	}
}


/// A Sequence ticks all its children as long as they return SUCCESS. If any child returns FAILURE, the sequence is aborted.
public class Sequence: CompositeBehavior {
	
	public init(name: String, @CompositeBehaviorResultBuilder _ content: () -> [Behavior]) {
		super.init(name: "Sequence", category: .sequence)
		children = content()
	}
//	
	public init() {
		super.init(name: "Sequence", category: .sequence)
		children = []
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public override func behave(entity: GKEntity?) {
		super.behave(entity: entity)
		if  runner != nil {
			runner.behave(entity: entity)
			state = runner.state
			if state == .running {
				return
			}
			else {
				self.runner = nil
			}
		}
		else {
			for behavior in children! {
				behavior.behave(entity: entity)
				if behavior.state == .fail {
					self.state = .fail
					return
				}
				if behavior.state == .running {
					state = .running
					handleRunner(runner: behavior)
					return
				}
			}
		}
	}
}



public class Selector: CompositeBehavior {
	
	public init(name: String, @CompositeBehaviorResultBuilder _ content: () -> [Behavior]) {
		super.init(name: "Selector", category: .sequence)
		children = content()
	}
	
	public init() {
		super.init(name: "Selector", category: .selector)
		children = []
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public override func behave(entity: GKEntity?) {
		super.behave(entity: entity)
		if  runner != nil {
			runner.behave(entity: entity)
			state = runner.state
			if state == .running {
				return
			}
			else {
				self.runner = nil
			}
		}
		else {
			for behavior in children! {
				behavior.behave(entity: entity)
				if behavior.state == .success {
					state = .success
					return
				}
				if behavior.state == .running {
					state = .running
					handleRunner(runner: behavior)
					return
				}
			}
			
		}
	}
}



public class Parallel: CompositeBehavior {
	
	public init(name: String, @CompositeBehaviorResultBuilder _ content: () -> [Behavior]) {
		super.init(name: "Parallel", category: .sequence)
		children = content()
	}
	
	public init() {
		super.init(name: "Parallel", category: .parallel)
		children = []
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public override func behave(entity: GKEntity?) {
		super.behave(entity: entity)
		if  runner != nil {
			runner.behave(entity: entity)
			state = runner.state
			if state == .running {
				return
			}
			else {
				self.runner = nil
			}
		}
		else {
			for behavior in children! {
				behavior.behave(entity: entity)
				if behavior.state == .fail {
					state = .fail
					handleRunner(runner: behavior)
				}
			}
		}
	}
}


