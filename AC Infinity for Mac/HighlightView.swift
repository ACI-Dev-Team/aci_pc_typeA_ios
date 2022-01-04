//
//  HighlightView.swift
//  AC Infinity for Mac
//
//  Created by cooltron on 2021/7/9.
//

import Cocoa

class HighlightView: NSTableRowView {

    
    var cell : NSTableCellView?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none {
            
            let temprect = NSInsetRect(self.bounds, 0, 0)
            Color.blueColor.setFill()
            let path = NSBezierPath.init(roundedRect: temprect, xRadius: 0, yRadius: 0)
            path.fill()
            
        }
    }
//    - (void)drawSelectionInRect:(NSRect)dirtyRect {
//        if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
//            NSRect selectionRect = NSInsetRect(self.bounds, 0, 0);
//            [[NSColor yellowColor] setFill];
//            NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:0 yRadius:0];
//            [selectionPath fill];
//        }
//    }
}
