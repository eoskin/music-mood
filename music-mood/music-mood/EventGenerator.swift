//
//  EventGenerator.swift
//  music-mood
//
//  Created by Eugene Oskin on 08.10.16.
//  Copyright © 2016 Eugene Oskin. All rights reserved.
//

import Cocoa

class EventGenerator {
    
    var timer: Timer!
    let periodSeconds: TimeInterval = 10
    let mask = NSEventMask.keyDown
        .union(NSEventMask.keyUp)
        .union(NSEventMask.mouseMoved)
        .union(NSEventMask.leftMouseDown)
        .union(NSEventMask.leftMouseUp)
        .union(NSEventMask.leftMouseDragged)
        .union(NSEventMask.rightMouseDown)
        .union(NSEventMask.rightMouseUp)
        .union(NSEventMask.rightMouseDragged)
        .union(NSEventMask.scrollWheel);
    
    let block: (_: Double) -> ()
    let counter = Counter()
    
    init(block: @escaping (_: Double) -> ()) {
        self.block = block
    }
    func start() {
        NSEvent.addGlobalMonitorForEvents(matching: mask, handler:
            { (event: NSEvent) in self.handleEvent(event: event)}
        )
        NSEvent.addLocalMonitorForEvents(matching: mask, handler:
            { (event: NSEvent) in self.handleEvent(event: event)}
        )
        timer = Timer.scheduledTimer(
            timeInterval: periodSeconds,
            target: self, selector: #selector(refire),
            userInfo: nil, repeats: true
        )
    }
    
    func handleEvent(event: NSEvent) -> NSEvent {
        counter.add(timestamp: event.timestamp);
        return event;
    }
    
    @objc func refire() {
        if (counter.value != 0) {
            self.block(counter.frequency)
        }
    }
}

class Counter {
    var value: Double = 0;
    var firstTimestamp: Double = 0;
    var lastTimestamp: Double = 0;
    
    var frequency : Double {
        get {
            return value / (lastTimestamp - firstTimestamp)
        }
    }
    
    func add(timestamp: Double) {
        if (value != 0) {
            lastTimestamp = timestamp
        } else {
            firstTimestamp = timestamp
        }
        value += 1
    }
}
