//
//  ProtocolBuffersExtension.swift
//  StreamingProtobufExample
//
//  Created by Suresh Joshi on 2016-04-18.
//  Copyright © 2016 Suresh Joshi. All rights reserved.
//

import ProtocolBuffers

extension GeneratedMessage {
    func writeDelimitedTo(outputStream: NSOutputStream) throws -> Int {
        var messageSize = Int32(littleEndian: self.serializedSize())
        withUnsafePointer(&messageSize) {
            outputStream.write(UnsafePointer($0), maxLength: sizeofValue(messageSize))
        }
        try self.writeToOutputStream(outputStream)
        return Int(messageSize + 4)
    }
}

extension Array where Element:GeneratedMessage {
    func writeDelimitedTo(outputStream: NSOutputStream) throws -> Int {
        var writtenSize = 0;
        for message in self {
            writtenSize += try message.writeDelimitedTo(outputStream)
        }
        return writtenSize
    }
}

extension GeneratedMessageProtocol {
    static func readDelimitedFrom(inputStream: NSInputStream) throws -> Self {
        var sizeBuffer: [UInt8] = [0,0,0,0]
        inputStream.read(&sizeBuffer, maxLength: sizeBuffer.count)
        let data = NSData(bytes: sizeBuffer, length: sizeBuffer.count)
        let messageSize = Int(data.uint32.littleEndian)
        
        var buffer = Array<UInt8>(count: messageSize, repeatedValue: 0)
        inputStream.read(&buffer, maxLength: messageSize)
        
        let messageData = NSData(bytes: buffer, length:messageSize)
        
        return try self.parseFromData(messageData)
    }
    
//    static func readDelimitedFrom(inputStream: NSInputStream) throws -> [GeneratedMessageProtocol] {
//        var messages = Array<GeneratedMessageProtocol>()
//        while inputStream.hasBytesAvailable {
//            try messages.append(self.readDelimitedFrom(inputStream))
//        }
//        return messages
//    }

}