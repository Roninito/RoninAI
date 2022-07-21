//
//  File.swift
//  
//
//  Created by leerie simpson on 10/4/21.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers
import GameplayKit



/// When a behavior is called via the sysnapse system, "behaviorName-sensation contains" any temporary
/// information sent by the sensation before the behavior is run. The behavior can lookup the information
/// by key (behaviorName + "-" + sensatiton) in the memory component.
open class Behavior: NSObject, Identifiable, NSSecureCoding, ObservableObject {
	
	/// The type descriptor for behavior being managed by drag and drop.
	public static let uTType = UTType("com.astra.behavior")!
	
	public var accentColor: Color = .green
	
	/// Describes the general type of behavior and is used tto generate iconography for the views.
	public enum Category: String, Codable {
		case action, condition, decorator, parallel, sequence, selector, reference
	}
	
	/// Describes the one of four states a Behavior will be in at any time.
	public enum  BehaviorState: String, Codable {
		case ready, fail, success, running
	}
	
	
	/// The unique identifier of this behavior.
	public var id: String = UUID().uuidString //.split(by: 10).first!
	
	/// Returns a new proxy for this behavior.
	public lazy var proxy: BehaviorProxy = BehaviorProxy(behavior: self)
	
	/// Generally when the behavior is run, all nodes are set to the ready state.
	/// When a behavior begins running it switches to that state. When a completes
	/// it will be either still running, success or fail. Each behavior retains this state
	/// until the behavior is reset.
	@Published public var state: BehaviorState = .ready
	
	public var behaviorSubscriptions = Set<AnyCancellable>()
	
	public var name: String = ""
	public var category: Category
	public var parent: Behavior?
	public var children: [Behavior]?

	
	public var configurationView: AnyView!
	public lazy var dropDelegate = BehaviorDropDelegate(behavior: self)

	
	///
	public override init() {
		self.name = "Unnamed"
		self.category = .action
		super.init()
	}
	
	
	public init(name: String, category: Category) {
		self.category = category
		super.init()
		self.name = name
	}
	
	
	// MARK: - NSSecuredCoding
	

	public static var supportsSecureCoding: Bool { true }
	
	
	public required init?(coder: NSCoder) {
		let categoryValue = coder.decodeObject(of: NSString.self, forKey: "category")! as String
		category = Category(rawValue: categoryValue)!
		
		let statusValue = coder.decodeObject(of: NSString.self, forKey: "status")! as String
		state = BehaviorState(rawValue: statusValue)!
		
		super.init()
		name = coder.decodeObject(of: NSString.self, forKey: "name")! as String
		parent = coder.decodeObject(of: Behavior.self, forKey: "parent")
		children = coder.decodeObject(of: [NSArray.self, Behavior.self], forKey: "children") as? [Behavior]
	}
	
	
	public func encode(with coder: NSCoder) {
		coder.encode(name, forKey: "namme")
		coder.encode(parent, forKey: "parent")
		coder.encode(children, forKey: "children")
		coder.encode(category.rawValue as NSString, forKey: "category")
		coder.encode(state.rawValue as NSString, forKey: "status")
	}
	
	
	///
	open func behave(entity: GKEntity?) {
		state = BehaviorState.running
	}
	
	
	/// Resets the state of the component to ready and propagates reset to all children if any.
	public func reset() {
		state = .ready
		children?.forEach {
			$0.parent = self
			$0.reset()
		}
	}
	
	
	public func depth(deepness: Int) -> Int {
		let currentDepth = deepness + 1
		if children != nil {
			let depths = children!.compactMap({
				$0.depth(deepness: currentDepth)
			})
			let maxChildDepth = depths.sorted(by: >).first ?? currentDepth
			return maxChildDepth
		}
		return currentDepth
	}
	
	
	/// Returns an array containing this node and all nodes in this node branch.
	/// If called on a root behavior returns every node in the tree.
	public func all() -> [Behavior] {
		var allNodes = [self]
		if let childNodes = children {
			for node in childNodes {
				allNodes.append(contentsOf: node.all())
			}
		}
		return allNodes
	}
	
	
	// MARK: - Child Behavior Management
	
	/// Adds the given behavior to the front of this one's children's list and sets its parentage.
	func add(asFirstChild behavior: Behavior) {
		children?.insert(behavior, at: 0)
		behavior.parent = self
		objectWillChange.send()
	}
	
	
	/// Adds the given behavior to this the end of this ones childrens list if it is a composite or decorator.
	func add(asLastChild behavior: Behavior) {
		children?.append(behavior)
		behavior.parent = self
		objectWillChange.send()
	}
	
	
	//
	func add(AsOlderSibling behavior: Behavior) {
		if let parent = self.parent, parent.category != .decorator {
			var index = parent.children!.firstIndex(of: self)!
			index -= 1
			index = max(index, 0)
			parent.children!.insert(behavior, at: index)
			behavior.parent = self.parent
			parent.objectWillChange.send()
		}
		else {
			print("Root or Decorated behavior cannot have siblings. Drop operation failed for behavior: \(behavior.name)")
		}
	}
	
	
	// to the left of this behavior.
	func add(asYoungerSibling behavior: Behavior) {
		if let parent = self.parent {
			var index = parent.children!.firstIndex(of: self)!
			index += 1
			parent.children!.insert(behavior, at: index)
			behavior.parent = self.parent
			parent.objectWillChange.send()
		}
		else {
			print("Root behavior cannot have siblings. Drop operation failed for behavior: \(behavior.name)")
		}
	}
	
	
	func add(asDecorator behavior: Behavior) {
		if behavior.category == .decorator {
			let decorator = behavior
			if let parent = self.parent {
				let index = parent.children!.firstIndex(of: self)!
				decorator.children = [self]
				parent.children!.remove(at: index)
				parent.children!.insert(decorator, at: max(index - 1, 0))
				decorator.parent = parent
				self.parent = decorator
				objectWillChange.send()
			}
			else {
				print("Root Nodes cannot be decorated by dragging and dropping. They must be managed in the context menu at this point.")
			}
		}
		else {
			print("Only decorators can decorate behavior.")
		}
	}
}
