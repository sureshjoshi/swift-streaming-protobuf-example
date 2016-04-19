//
//  ViewController.swift
//  StreamingProtobufExample
//
//  Created by Suresh Joshi on 2016-04-18.
//  Copyright © 2016 Suresh Joshi. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var addSingleButton: UIButton!
    @IBOutlet weak var addTenButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    
    var runningX: UInt32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.lineChartView.delegate = self
        self.lineChartView.descriptionTextColor = UIColor.whiteColor()
        self.lineChartView.gridBackgroundColor = UIColor.darkGrayColor()
        self.lineChartView.noDataText = "No data provided"
        
        addSingleButton.addTarget(self, action: #selector(ViewController.addOneSample), forControlEvents: .TouchUpInside)
        addTenButton.addTarget(self, action: #selector(ViewController.addTenSamples), forControlEvents: .TouchUpInside)
        refreshButton.addTarget(self, action: #selector(ViewController.refreshChart), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        outputStream = NSOutputStream.outputStreamToMemory()
        outputStream?.open()
        refreshChart()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        outputStream?.close()
    }

    func addOneSample() {
        let sample = try! Sureshjoshi.Pb.Sample.Builder()
            .setX(++runningX)
            .setY(UInt32(arc4random_uniform(1000)))
            .build()

        try! sample.writeDelimitedTo(outputStream!)
        refreshChart();
    }

    func addTenSamples() {
        var samples = Array<Sureshjoshi.Pb.Sample>()
        for _ in 0 ..< 10 {
            samples.append(try! Sureshjoshi.Pb.Sample.Builder()
                .setX(++runningX)
                .setY(UInt32(arc4random_uniform(1000)))
                .build())
        }
    
        try! samples.writeDelimitedTo(outputStream!)
        refreshChart();
    }
    
    
    func refreshChart() {
        // Read in from the file, clear and remake chart
        let data = outputStream!.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as! NSData
        inputStream = NSInputStream(data: data)
        inputStream?.open()
        let samples = try! Sureshjoshi.Pb.Sample.readAllDelimitedFrom(inputStream!)
        inputStream?.close()
        
        
        // Everything below here is specifically for Charts
        // Setup samples to work with MPAndroid charting
        var xVals = [String]()
        var yVals = [ChartDataEntry]()
        for i in 0 ..< samples.count {
            xVals.append(String(samples[i].x))
            yVals.append(ChartDataEntry(value: Double(samples[i].y), xIndex: i))
        }
        
        // Create a dataset and give it a type
        let dataSet:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "Dataset 1")
        dataSet.lineWidth = 1
        dataSet.drawCirclesEnabled = false
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(dataSet)
        
        // Create a data object with the datasets
        let lineData: LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        lineData.setValueTextColor(UIColor.whiteColor())
        
        // Set data
        lineChartView.data = lineData
    }

}

