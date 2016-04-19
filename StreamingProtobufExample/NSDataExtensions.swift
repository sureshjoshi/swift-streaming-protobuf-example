//
//  NSDataExtensions.swift
//  StreamingProtobufExample
//
//  Created by Suresh Joshi on 2016-04-18.
//  Copyright © 2016 Suresh Joshi. All rights reserved.
//

import Foundation

extension NSData {
    
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.getBytes(&number, length: sizeof(UInt8))
            return number
        }
    }
    
    var uint16: UInt16 {
        get {
            var number: UInt16 = 0
            self.getBytes(&number, length: sizeof(UInt16))
            return number
        }
    }
    
    var uint32: UInt32 {
        get {
            var number: UInt32 = 0
            self.getBytes(&number, length: sizeof(UInt32))
            return number
        }
    }
}

extension Int {
    
    var data: NSData {
        var int = self
        return NSData(bytes: &int, length: sizeof(Int))
    }
    
}

extension UInt8 {
    
    var data: NSData {
        var int = self
        return NSData(bytes: &int, length: sizeof(UInt8))
    }
    
}

extension UInt16 {
    
    var data: NSData {
        var int = self
        return NSData(bytes: &int, length: sizeof(UInt16))
    }
    
}

extension UInt32 {
    
    var data: NSData {
        var int = self
        return NSData(bytes: &int, length: sizeof(UInt32))
    }
    
}