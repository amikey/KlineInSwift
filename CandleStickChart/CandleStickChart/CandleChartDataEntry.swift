//
//  CandleChartDataEntry.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//
import UIKit
import Foundation

public class CandleChartDataEntry: ChartDataEntry
{
    /// shadow-high value
    public var high = Float(0.0)
    
    /// shadow-low value
    public var low = Float(0.0)
    
    /// close value
    public var close = Float(0.0)
    
    /// open value
    public var open = Float(0.0)
    
    ///Volume value
    public var volume = Float(0.0)
    
    ///MA5 value
    
    public var RISvalues = Float(0.0)
    
    public var KDJvalues = Float(0.0)
    
    public var MACDvalues = Float(0.0)
    
    public var WRvalues = Float(0.0)
    
    public var DMIvalues = Float(0.0)
    
    public var BIASvalues = Float(0.0)
    
    public var OBVvalues = Float(0.0)
    
    public var CCIvalues = Float(0.0)
    
    public var ROCvalues = Float(0.0)
    
    public var CRvalues = Float(0.0)
    
    public var BOLLvalues = Float(0.0)
    
    
    public init(xIndex: Int, shadowH: Float, shadowL: Float, open: Float, close: Float)
    {
        super.init(value: (shadowH + shadowL) / 2.0, xIndex: xIndex);
        
        self.high = shadowH;
        self.low = shadowL;
        self.open = open;
        self.close = close;
    }
    
    public init(xIndex: Int, shadowH: Float, shadowL: Float, open: Float, close: Float,volume:Float,movingAveragefive:Float)
    {
        super.init(value: (shadowH + shadowL) / 2.0, xIndex: xIndex);
        
        self.high = shadowH;
        self.low = shadowL;
        self.open = open;
        self.close = close;
        self.volume = volume;
        self.MACDvalues = movingAveragefive;
    }
    
    
    public init(xIndex: Int, shadowH: Float, shadowL: Float, open: Float, close: Float, data: AnyObject?)
    {
        super.init(value: (shadowH + shadowL) / 2.0, xIndex: xIndex, data: data);
        
        self.high = shadowH;
        self.low = shadowL;
        self.open = open;
        self.close = close;
    }
    
    /// Returns the overall range (difference) between shadow-high and shadow-low.
    public var shadowRange: Float
        {
            return abs(high - low);
    }
    
    /// Returns the body size (difference between open and close).
    public var bodyRange: Float
        {
            return abs(open - close);
    }
    
    /// the center value of the candle. (Middle value between high and low)
    public override var value: Float
        {
        get
        {
            return super.value;
        }
        set
        {
            super.value = (high + low) / 2.0;
        }
    }
    //line of RIS
    public  var RIS: Float
        {
            return RISvalues;
    }
    //line of KDJ
    public  var KDJ: Float
        {
            return KDJvalues;
    }
    //line of MACD
    public  var MACD: Float
        {
            return MACDvalues;
    }
    //line of WR
    public  var WR: Float
        {
            return WRvalues;
    }
    //line of DMI
    public  var DMI: Float
        {
            return DMIvalues;
    }
    //line of BIAS
    public  var BIAS: Float
        {
            return BIASvalues;
    }
    //line of OBV
    public  var OBV: Float
        {
            return OBVvalues;
    }
    //line of CCI
    public  var CCI: Float
        {
            return CCIvalues;
    }
    //line of ROC
    public  var ROC: Float
        {
            return ROCvalues;
    }
    //line of CR
    public  var CR: Float
        {
            return CRvalues;
    }
    //line of BOLL
    public var BOLL:Float
        {
            return BOLLvalues;
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = super.copyWithZone(zone) as! CandleChartDataEntry;
        copy.high = high;
        copy.high = low;
        copy.high = open;
        copy.high = close;
        return copy;
    }
}