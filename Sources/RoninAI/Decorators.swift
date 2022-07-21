//
//  File.swift
//  
//
//  Created by leerie simpson on 10/4/21.
//

import Foundation


public class DecoratingBehavior: Behavior {
	
	public init(name: String) {
		super.init(name: name, category: .decorator)
		children = []
	}
	
	public init(name: String, behavior decoratedBehavior: Behavior) {
		super.init(name: name, category: .decorator)
		children = [decoratedBehavior]
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public override func encode(with coder: NSCoder) {
		super.encode(with: coder)
	}
}
