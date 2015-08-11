//
//  ViewController.swift
//  CandleStick
//
//  Created by 彬海 朱 on 15/5/5.
//  Copyright (c) 2015年 zbh. All rights reserved.
//
import UIKit


class ViewController: UIViewController,ChartViewDelegate {
    
    var chartView:CandleStickChartView!
    var candleData:NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let defauts = NSUserDefaults.standardUserDefaults()
//        var dataA = defauts.objectForKey("data") as! NSArray!
//        println(dataA)
        
//        if (dataA == nil){
        
        var url = NSURL(string: "http://ichart.yahoo.com/table.csv?s=000001.SZ&g=d")

        var sesstion = NSURLSession.sharedSession()
        sesstion.dataTaskWithURL(url!, completionHandler: { (dataString, NSURLResponse, NSError) -> Void in
            var datastr = NSString(data: dataString, encoding: NSUTF8StringEncoding)
            var dataArray = datastr!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as NSArray!
//            println(dataArray)
            //数组反序
            var dataB = dataArray.reverseObjectEnumerator().allObjects as NSArray!
            println(dataB.count)
            
            let defauts = NSUserDefaults.standardUserDefaults()
            defauts.setObject(dataArray, forKey: "data")
            
            var range = NSMakeRange(dataB.count - 71, 70)
            var indexSet = NSIndexSet(indexesInRange: range)
            self.candleData =  dataB.objectsAtIndexes(indexSet)
            self.addKlineChart()
        }).resume()

//        }else{
//            //已经有缓存数据
//            let defauts = NSUserDefaults.standardUserDefaults()
//            var dataA = defauts.objectForKey("data") as! NSArray!
//            var dataB = dataA.reverseObjectEnumerator().allObjects as NSArray!
//            println(dataB.count)
//            var range = NSMakeRange(dataB.count - 71, 70)
//            var indexSet = NSIndexSet(indexesInRange: range)
//            self.candleData =  dataB.objectsAtIndexes(indexSet)
//            self.addKlineChart()
//        }
    
        
    }
    //K线
    func addKlineChart(){
        self.chartView = CandleStickChartView(frame: CGRectMake(0, 100, self.view.bounds.width, 270))
        self.chartView.delegate = self;
        self.chartView.backgroundColor = UIColor.clearColor()
        self.chartView.pinchZoomEnabled = false
        self.chartView.descriptionText = "descriptionText"
        self.chartView.noDataTextDescription = "noDataTextDescription"
        self.chartView.maxVisibleValueCount = 260;
        self.chartView.drawGridBackgroundEnabled = false
        
        //X轴显示的分割线
        self.chartView.xAxis.labelPosition = .Bottom
        self.chartView.xAxis.spaceBetweenLabels = 2
        self.chartView.xAxis.drawGridLinesEnabled = true
        
        //Y轴显示的分割线
        self.chartView.leftAxis.labelCount = 3
        self.chartView.leftAxis.drawGridLinesEnabled = true
        self.chartView.leftAxis.drawAxisLineEnabled = false
        self.chartView.leftAxis.startAtZeroEnabled = true
        
        self.chartView.legend.enabled = false
        self.chartView.scaleYEnabled = false
        
        var rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        var xVals:[String] = []
        
        var yVals1 :[CandleChartDataEntry] = []
        var count = self.candleData.count
        println(self.candleData)
        
//        for(var i = count - 1;i > 0;i--)
            for(var i=0;i<self.candleData.count;i++)
        {
            var content: String =  candleData.objectAtIndex(i) as! String
            //过滤空的字符串
            if (!content.isEmpty){
                
                var dataArray = content.componentsSeparatedByString(",") as NSArray
                let date = dataArray.objectAtIndex(0) as! String//日期
                let openPrice = atof(dataArray.objectAtIndex(1) as! String)//开盘价
                let highPrice = atof(dataArray.objectAtIndex(2) as! String)//最高价
                let lowPrice = atof(dataArray.objectAtIndex(3) as! String)//最低价
                let closePrice = atof(dataArray.objectAtIndex(4) as! String)//收盘价
                let valPrice = atof(dataArray.objectAtIndex(5) as! String)//成交量
                let mafivePrice = atof(dataArray.objectAtIndex(6) as! String)//五日均线
                
                var open: Float = Float(openPrice)
                var high: Float = Float(highPrice)
                var low: Float = Float(lowPrice)
                var close: Float = Float(closePrice)
                var val: Float = Float(valPrice)
                var movingAveragefive: Float = Float(mafivePrice)
                
                //时间轴
                xVals.append(date)
                
                var Candle1 = CandleChartDataEntry(xIndex: i, shadowH: high, shadowL: low, open: open, close: close, volume: val, movingAveragefive: movingAveragefive)
                yVals1.append(Candle1)
                
            }
        }
        
        var set1 = CandleChartDataSet(yVals: yVals1, label: "dd")
        set1.axisDependency = .Left
        set1.decreasingColor = UIColor(red: 60/255.0, green: 175/255.0, blue: 100/255.0, alpha: 1.0)
        set1.increasingColor = UIColor(red: 246/255.0, green: 69/255.0, blue: 87/255.0, alpha: 1.0)
        set1.increasingFilled = true
        set1.decreasingFilled = true
        set1.highlightColor = UIColor.grayColor()
        
        var data = CandleChartData(xVals: xVals, dataSet: set1)
        self.chartView.data = data
        self.chartView.animate(xAxisDuration: 1.5)
        self.view.addSubview(chartView)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        print("\(chartView)")
        print("\(entry)")
        print("\(dataSetIndex)")
        print("\(highlight)")
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        
    }
    
    func doubleTapGestureRecognizedDelegate(chartView: ChartViewBase) {
        print("changLandscape")
        var landscape = LandscapeViewController()
        self.presentViewController(landscape, animated: true, completion: nil)
    }
    
    //屏幕旋转
    override func shouldAutorotate() -> Bool {
        return true
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

