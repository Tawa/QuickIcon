//
//  AppDelegate.swift
//  QuickIcon
//
//  Created by Tawa Nicolas on 22.09.19.
//  Copyright © 2019 Tawa Nicolas. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	private func disableZoomButton() {
		for window in NSApplication.shared.windows {
			let button = window.standardWindowButton(NSWindow.ButtonType.zoomButton)
			button?.isEnabled = false
		}
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		disableZoomButton()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}
}

