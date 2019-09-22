//
//  ViewController.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet private weak var label: NSTextField!
	@IBOutlet private weak var progressIndicator: NSProgressIndicator!
	@IBOutlet private weak var buttons: NSStackView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

