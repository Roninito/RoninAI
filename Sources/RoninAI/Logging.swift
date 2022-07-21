//
//  File.swift
//  
//
//  Created by leerie simpson on 10/5/21.
//

import Foundation
import GameplayKit


public class Logging: Behavior {
	
	public var logEntry: String = ""
	
	public init(_ logEntry: String) {
		self.logEntry = logEntry
		super.init(name: "Logging Behavior", category: .action)
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		logEntry = coder.decodeObject(of: NSString.self, forKey: "logEntry")! as String
	}
	
	public override func encode(with coder: NSCoder) {
		super.encode(with: coder)
		coder.encode(logEntry as NSString, forKey: "logEntry")
	}
	
	public override func behave(entity: GKEntity?) {
		super.behave(entity: entity)
		print(logEntry)
		state = .success
	}
}
