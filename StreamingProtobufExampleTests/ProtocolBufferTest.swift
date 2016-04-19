//
//  StreamingProtobufExampleTests.swift
//  StreamingProtobufExampleTests
//
//  Created by Suresh Joshi on 2016-04-18.
//  Copyright © 2016 Suresh Joshi. All rights reserved.
//

import XCTest
@testable import StreamingProtobufExample

class ProtocolBufferTest: XCTestCase {
    
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    
    override func setUp() {
        super.setUp()
        outputStream = NSOutputStream.outputStreamToMemory()
        outputStream?.open()
    }
    
    override func tearDown() {
        super.tearDown()
        outputStream?.close()
        inputStream?.close()
    }
    
    func testWriteWithLengthPrefix_withSingleSample_streamsCorrectSize() {
        let kSampleSize:UInt32 = 4;
        let kMessageSize = 8;
//        
        let sample = try! Sureshjoshi.Pb.Sample.Builder()
            .setX(42)
            .setY(84)
            .build()

        let encodedSize = try! sample.writeDelimitedTo(outputStream!)

        // Check if total returned encoded size is what we expect
        XCTAssertEqual(kMessageSize, encodedSize)

        // Make sure total returned size is same as the actual byte array length
        let data = outputStream!.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as! NSData
        XCTAssertEqual(encodedSize, data.length);

        // Check if initial length is 4-byte, little-endian, with the correct value
        XCTAssertEqual(kSampleSize, data.uint32);
    }
    
    func testWriteWithLengthPrefix_withMultipleSamples_streamsCorrectSize() {
        let kSampleSize:UInt32 = 4;
        let kMessagesSize = 40;
        let kNumberOfSamples = 5
        
        var samples = Array<Sureshjoshi.Pb.Sample>()
        for _ in 0 ..< kNumberOfSamples {
            samples.append(try! Sureshjoshi.Pb.Sample.Builder()
                .setX(42)
                .setY(84)
                .build())
        }
        
        let totalEncodedSize = try! samples.writeDelimitedTo(outputStream!)
        
        // Check if total returned encoded size is what we expect
        XCTAssertEqual(kMessagesSize, totalEncodedSize);
        
        // TODO: Finish these
        // Make sure total returned size is same as the actual byte array length
        let data = outputStream!.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as! NSData
        XCTAssertEqual(totalEncodedSize, data.length);
        
        // Check if initial length is 4-byte, little-endian, with the correct value
        XCTAssertEqual(kSampleSize, data.uint32.littleEndian);
    
    }
    
    func testWriteThenRead_withSingleSample_returnsSameResult() {
        let sample = try! Sureshjoshi.Pb.Sample.Builder()
            .setX(42)
            .setY(84)
            .build()

        try! sample.writeDelimitedTo(outputStream!)
        let data = outputStream!.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as! NSData
        inputStream = NSInputStream(data: data)
        inputStream?.open()
        
        let decodedSample = try! Sureshjoshi.Pb.Sample.readDelimitedFrom(inputStream!)
        
        XCTAssertEqual(sample.x, decodedSample.x)
        XCTAssertEqual(sample.y, decodedSample.y)
        
    }

    func testWriteThenRead_withMultipleSamples_returnsSameResult() {
        let kNumberOfSamples = 5
        
        var samples = Array<Sureshjoshi.Pb.Sample>()
        for _ in 0 ..< kNumberOfSamples {
            samples.append(try! Sureshjoshi.Pb.Sample.Builder()
                .setX(42)
                .setY(84)
                .build())
        }
        
        let _ = try! samples.writeDelimitedTo(outputStream!)
        
        let data = outputStream!.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as! NSData
        inputStream = NSInputStream(data: data)
        inputStream?.open()
        let decodedSamples = try! Sureshjoshi.Pb.Sample.readAllDelimitedFrom(inputStream!)
        inputStream?.close()
        
        XCTAssertEqual(kNumberOfSamples, decodedSamples.count)
        
        for var decodedSample in decodedSamples {
            XCTAssertEqual(42, decodedSample.x)
            XCTAssertEqual(84, decodedSample.y)
        }
    }

    
}
