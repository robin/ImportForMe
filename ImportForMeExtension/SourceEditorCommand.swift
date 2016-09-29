//
//  SourceEditorCommand.swift
//  ImportForMeExtension
//
//  Created by Lu Yibin on 29/09/2016.
//  Copyright © 2016 Lu Yibin. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        var lastImportLine = 0
        let regex = try! NSRegularExpression(pattern: "^\\s*import\\s*\\w", options: [])
        for (i, line) in invocation.buffer.lines.enumerated() {
            if let buffer = line as? String {
                if let result = regex.firstMatch(in: buffer, options: [], range: buffer.fullRange) {
                    if result.range.location != NSNotFound {
                        lastImportLine = i
                    }
                }
            }
        }
        let lastWordRegex = try! NSRegularExpression(pattern: "\\s*([\\w.]+)\\W*$", options: [])
        if let range = invocation.buffer.selections[0] as? XCSourceTextRange {
            if let currentLine = invocation.buffer.lines[range.start.line] as? String {
                if let result = lastWordRegex.firstMatch(in: currentLine, options: [], range: currentLine.fullRange) {
                    if result.numberOfRanges > 1 {
                        let wordRange = result.rangeAt(1)
                        let word = (currentLine as NSString).substring(with: wordRange)
                        if !word.isEmpty {
                            invocation.buffer.lines.insert("import \(word)", at: lastImportLine+1)
                            invocation.buffer.lines.removeObject(at: range.start.line)
                        }
                    }
                }
            }
        }
        completionHandler(nil)
    }
}

extension String {
    
    var fullRange: NSRange {
        return NSRange(location: 0, length: characters.count)
    }
    
}
