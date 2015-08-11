//
//  CandleStickChartRenderer.swift
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

/**
*  渲染
*/

@objc
public protocol CandleStickChartRendererDelegate
{
    func candleStickChartRendererCandleData(renderer: CandleStickChartRenderer) -> CandleChartData!;
    func candleStickChartRenderer(renderer: CandleStickChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!;
    func candleStickChartDefaultRendererValueFormatter(renderer: CandleStickChartRenderer) -> NSNumberFormatter!;
    func candleStickChartRendererChartYMax(renderer: CandleStickChartRenderer) -> Float;
    func candleStickChartRendererChartYMin(renderer: CandleStickChartRenderer) -> Float;
    func candleStickChartRendererChartXMax(renderer: CandleStickChartRenderer) -> Float;
    func candleStickChartRendererChartXMin(renderer: CandleStickChartRenderer) -> Float;
    func candleStickChartRendererMaxVisibleValueCount(renderer: CandleStickChartRenderer) -> Int;
}

public class CandleStickChartRenderer: ChartDataRendererBase
{
    public weak var delegate: CandleStickChartRendererDelegate?;
    
    public init(delegate: CandleStickChartRendererDelegate?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler);
        
        self.delegate = delegate;
    }
    
    public override func drawData(#context: CGContext)
    {
        var candleData = delegate!.candleStickChartRendererCandleData(self);
        
        for set in candleData.dataSets as! [CandleChartDataSet]
        {
            if (set.isVisible)
            {
                drawDataSet(context: context, dataSet: set);
            }
        }
    }
    @objc//lineStlye
    public enum KLineStlye:Int
    {
        case RIS
        case KDJ
        case MACD
        case WR
        case DMI
        case BIAS
        case OBV
        case CCI
        case ROC
        case CR
        case BOLL
    }
    
    public var klineStlye = KLineStlye.self
    private var _shadowPoints = [CGPoint](count: 2, repeatedValue: CGPoint());
    private var _bodyRect = CGRect();
    private var _volumebodyRect = CGRect();
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint());
    
    internal func drawDataSet(#context: CGContext, dataSet: CandleChartDataSet)
    {
        var candleData = delegate!.candleStickChartRendererCandleData(self);

        var trans = delegate!.candleStickChartRenderer(self, transformerForAxis: dataSet.axisDependency);
        calcXBounds(trans);
        var valueToPixelMatrix = trans.valueToPixelMatrix;
        var phaseX = _animator.phaseX;
        var phaseY = _animator.phaseY;
        var bodySpace = dataSet.bodySpace;
        
        var dataSetIndex = candleData.indexOfDataSet(dataSet);
        
        var entries = dataSet.yVals as! [CandleChartDataEntry];
        
        var entryFrom = dataSet.entryForXIndex(_minX);
        var entryTo = dataSet.entryForXIndex(_maxX);
        
        var minx = dataSet.entryIndex(entry: entryFrom, isEqual: true);
        var maxx = min(dataSet.entryIndex(entry: entryTo, isEqual: true) + 1, entries.count);
        
        CGContextSaveGState(context);
        
        CGContextSetLineWidth(context, dataSet.shadowWidth);
        
        for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j++)
        {
            // 获得K线数据
            var e = entries[j];
            
            if (e.xIndex < _minX || e.xIndex > _maxX)
            {
                continue;
            }
            
            //成交量
            var val =  CGFloat(e.volume)
            
            //计算最高点和最低点
            _shadowPoints[0].x = CGFloat(e.xIndex);
            _shadowPoints[0].y = CGFloat(e.high) * phaseY;
            _shadowPoints[1].x = CGFloat(e.xIndex);
            _shadowPoints[1].y = CGFloat(e.low) * phaseY;
            
            trans.pointValuesToPixel(&_shadowPoints);
//            println(_shadowPoints)
            //计算K线体
            _bodyRect.origin.x = CGFloat(e.xIndex) - 0.5 + bodySpace;
            _bodyRect.origin.y = CGFloat(e.close) * phaseY;
            _bodyRect.size.width = (CGFloat(e.xIndex) + 0.5 - bodySpace) - _bodyRect.origin.x;
            _bodyRect.size.height = (CGFloat(e.open) * phaseY) - _bodyRect.origin.y;
            
            trans.rectValueToPixel(&_bodyRect);

            //成交量
            _volumebodyRect.origin.x = CGFloat(e.xIndex) - 0.5 + bodySpace;
            _volumebodyRect.origin.y = 0.0
            _volumebodyRect.size.width = (CGFloat(e.xIndex) + 0.5 - bodySpace) - _volumebodyRect.origin.x;
            _volumebodyRect.size.height = CGFloat(e.volume/100000000)*0.7;
            
            trans.rectValueToPixel(&_volumebodyRect);
            CGContextSetLineWidth(context, 0.8);
            // 开始画K线
            if (e.open >= e.close)
            {  //下降K线
                
                var color = dataSet.decreasingColor ?? dataSet.colorAt(j);
                //是否填充
                if (dataSet.isDecreasingFilled)
                {    // 画最高价和最低价之间的线
                    CGContextSetStrokeColorWithColor(context, UIColor(red: 60/255.0, green: 175/255.0, blue: 100/255.0, alpha: 1.0).CGColor);
                    CGContextStrokeLineSegments(context, _shadowPoints, 2);
                    // 画K线体
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextFillRect(context, _bodyRect);
                    //画成交量
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextFillRect(context, _volumebodyRect);
                }
                else
                {
                    // 画最高价和最低价之间的线
                    CGContextSetStrokeColorWithColor(context, UIColor(red: 60/255.0, green: 175/255.0, blue: 100/255.0, alpha: 1.0).CGColor);
                    CGContextStrokeLineSegments(context, _shadowPoints, 2);
                    // 画K线体
                    CGContextSetStrokeColorWithColor(context, color.CGColor);
                    CGContextStrokeRect(context, _bodyRect);
                    //画成交量
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextFillRect(context, _volumebodyRect);
                    
                }
            }
            else
            {
                //上升K线
                var color = dataSet.increasingColor ?? dataSet.colorAt(j);
                
                if (dataSet.isIncreasingFilled)
                {
                    // 画最高价和最低价之间的线
                    CGContextSetStrokeColorWithColor(context, UIColor(red: 246/255.0, green: 69/255.0, blue: 87/255.0, alpha: 1.0).CGColor);
                    CGContextStrokeLineSegments(context, _shadowPoints, 2);
                    // 画K线体
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextFillRect(context, _bodyRect);
                    //画成交量
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextFillRect(context, _volumebodyRect);
                }
                else
                {
                    // 画最高价和最低价之间的线
                    CGContextSetStrokeColorWithColor(context, UIColor(red: 246/255.0, green: 69/255.0, blue: 87/255.0, alpha: 1.0).CGColor);
                    CGContextStrokeLineSegments(context, _shadowPoints, 2);
                    // 画K线体
                    CGContextSetStrokeColorWithColor(context, color.CGColor);
                    CGContextStrokeRect(context, _bodyRect);
                    //画成交量
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextFillRect(context, _volumebodyRect);
                }
            }
        }
        
        //        // 画五日均线
        //        var point = CGPoint();
        //        point.x = CGFloat(entries[minx].xIndex);
        //        point.y = CGFloat(entries[minx].value) * phaseY;
        //        point = CGPointApplyAffineTransform(point, valueToPixelMatrix)
        //        CGContextBeginPath(context);
        //        CGContextMoveToPoint(context, point.x, point.y);
        //        for (var x = minx + 1, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); x < count; x++)
        //        {
        //            var e = entries[x];
        //            point.x = CGFloat(e.xIndex);
        //            point.y = CGFloat(e.value) * phaseY;
        //            point = CGPointApplyAffineTransform(point, valueToPixelMatrix)
        //            CGContextAddLineToPoint(context, point.x, point.y);
        //        }
        //        //均线属性设置
        //        CGContextSetLineWidth(context, 1);
        //        CGContextSetStrokeColorWithColor(context, UIColor(red: 242.0/255, green: 190.0/255, blue: 52.0/255, alpha: 1).CGColor);
        //        CGContextStrokePath(context);
        //
        //        // 画十日均线
        //        var point2 = CGPoint();
        //        point2.x = CGFloat(entries[minx].xIndex);
        //        point2.y = CGFloat(entries[minx].value) * phaseY;
        //        point2 = CGPointApplyAffineTransform(point2, valueToPixelMatrix)
        //        CGContextBeginPath(context);
        //        CGContextMoveToPoint(context, point2.x, point2.y);
        //        for (var x = minx + 1, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); x < count; x++)
        //        {
        //            var e = entries[x];
        //            point2.x = CGFloat(e.xIndex);
        //            point2.y = CGFloat(e.value) * phaseY - 1;
        //            point2 = CGPointApplyAffineTransform(point2, valueToPixelMatrix)
        //            CGContextAddLineToPoint(context, point2.x, point2.y);
        //        }
        //        //均线属性设置
        //        CGContextSetLineWidth(context, 1);
        //        CGContextSetStrokeColorWithColor(context, UIColor(red: 70.0/255, green: 165.0/255, blue: 197.0/255, alpha: 1).CGColor);
        //        CGContextStrokePath(context);
        //
        // 画二十日均线
        //        var point3 = CGPoint();
        //        point3.x = CGFloat(entries[minx].xIndex);
        //        point3.y = CGFloat(entries[minx].value) * phaseY;
        //        point3 = CGPointApplyAffineTransform(point3, valueToPixelMatrix)
        //        CGContextBeginPath(context);
        //        CGContextMoveToPoint(context, point3.x, point3.y);
        //        for (var x = minx + 1, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); x < count; x++)
        //        {
        //            var e = entries[x];
        //            point3.x = CGFloat(e.xIndex);
        //            point3.y = CGFloat(e.value) * phaseY - 3;
        //            point3 = CGPointApplyAffineTransform(point3, valueToPixelMatrix)
        //            CGContextAddLineToPoint(context, point3.x, point3.y);
        //        }
        //        //均线属性设置
        //        CGContextSetLineWidth(context, 1);
        //        CGContextSetStrokeColorWithColor(context, UIColor(red: 209.0/255, green: 109.0/255, blue: 179.0/255, alpha: 1).CGColor);
        //        CGContextStrokePath(context);
        
        self.drawline(context: context, entriesxIndex: entries[minx].xIndex, entriesxValue: entries[minx].value, valueToPixelMatrix: valueToPixelMatrix, phaseY: phaseY, phaseX: phaseX, minx: minx, maxx: maxx, entries: entries,lineColor:UIColor(red: 242.0/255, green: 190.0/255, blue: 52.0/255, alpha: 1).CGColor,klineStlye:KLineStlye.MACD)
        
          self.drawline(context: context, entriesxIndex: entries[minx].xIndex, entriesxValue: entries[minx].value, valueToPixelMatrix: valueToPixelMatrix, phaseY: phaseY, phaseX: phaseX, minx: minx, maxx: maxx, entries: entries,lineColor:UIColor(red: 70.0/255, green: 165.0/255, blue: 197.0/255, alpha: 1).CGColor,klineStlye:KLineStlye.RIS)
        
        self.drawline(context: context, entriesxIndex: entries[minx].xIndex, entriesxValue: entries[minx].value, valueToPixelMatrix: valueToPixelMatrix, phaseY: phaseY, phaseX: phaseX, minx: minx, maxx: maxx, entries: entries,lineColor:UIColor(red: 209.0/255, green: 109.0/255, blue: 179.0/255, alpha: 1).CGColor,klineStlye:KLineStlye.KDJ)
      
        CGContextRestoreGState(context);
    }
    
    //MARK:画任意一条线，只要传入值
    public func drawline(#context: CGContext, entriesxIndex: Int, entriesxValue: Float, valueToPixelMatrix:CGAffineTransform, phaseY:CGFloat,phaseX:CGFloat,minx:Int,maxx:Int,entries:[CandleChartDataEntry],lineColor:CGColor,klineStlye:KLineStlye){
        // 画五日均线
        var point = CGPoint();
        point.x = CGFloat(entriesxIndex);
        point.y = CGFloat(entriesxValue) * phaseY;
        point = CGPointApplyAffineTransform(point, valueToPixelMatrix)
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, point.x, point.y);
        for (var x = minx + 1, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); x < count; x++)
        {
            var e = entries[x];
            point.x = CGFloat(e.xIndex);
            
            if(klineStlye == .RIS){
                
//                point.y = CGFloat(e.RIS) * phaseY;
                   point.y = CGFloat(e.MACD) * phaseY + 2;
                
            }else if(klineStlye == .KDJ){
                
//                point.y = CGFloat(e.KDJ) * phaseY;
                 point.y = CGFloat(e.MACD) * phaseY + 5;
                
            }else if(klineStlye == .MACD){
                
                point.y = CGFloat(e.MACD) * phaseY;
                
            }else if(klineStlye == .WR){
                
                point.y = CGFloat(e.WR) * phaseY;
                
            }else if(klineStlye == .DMI){
                
                point.y = CGFloat(e.DMI) * phaseY;
                
            }else if(klineStlye == .BIAS){
                
                point.y = CGFloat(e.BIAS) * phaseY;
                
            }else if(klineStlye == .OBV){
                
                point.y = CGFloat(e.OBV) * phaseY;
                
            }else if(klineStlye == .CCI){
                
                point.y = CGFloat(e.CCI) * phaseY;
                
            }else if(klineStlye == .OBV){
                
                point.y = CGFloat(e.OBV) * phaseY;
                
            }else if(klineStlye == .ROC){
                
                point.y = CGFloat(e.ROC) * phaseY;
                
            }else if(klineStlye == .CR){
                
                point.y = CGFloat(e.CR) * phaseY;
                
            }else if(klineStlye == .BOLL){
                
                point.y = CGFloat(e.BOLL) * phaseY;
                
            }
            
            point = CGPointApplyAffineTransform(point, valueToPixelMatrix)
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        //均线属性设置
        CGContextSetLineWidth(context, 1);
        CGContextSetStrokeColorWithColor(context, lineColor);
        CGContextStrokePath(context);
    }
    
    
    public override func drawValues(#context: CGContext)
    {
        var candleData = delegate!.candleStickChartRendererCandleData(self);
        if (candleData === nil)
        {
            return;
        }
        
        var defaultValueFormatter = delegate!.candleStickChartDefaultRendererValueFormatter(self);
        
        // if values are drawn
        if (candleData.yValCount < Int(ceil(CGFloat(delegate!.candleStickChartRendererMaxVisibleValueCount(self)) * viewPortHandler.scaleX)))
        {
            var dataSets = candleData.dataSets;
            
            for (var i = 0; i < dataSets.count; i++)
            {
                var dataSet = dataSets[i];
                
                if (!dataSet.isDrawValuesEnabled)
                {
                    continue;
                }
                
                var valueFont = dataSet.valueFont;
                var valueTextColor = dataSet.valueTextColor;
                
                var formatter = dataSet.valueFormatter;
                if (formatter === nil)
                {
                    formatter = defaultValueFormatter;
                }
                
                var trans = delegate!.candleStickChartRenderer(self, transformerForAxis: dataSet.axisDependency);
                
                var entries = dataSet.yVals as! [CandleChartDataEntry];
                
                var entryFrom = dataSet.entryForXIndex(_minX);
                var entryTo = dataSet.entryForXIndex(_maxX);
                
                var minx = dataSet.entryIndex(entry: entryFrom, isEqual: true);
                var maxx = min(dataSet.entryIndex(entry: entryTo, isEqual: true) + 1, entries.count);
                
                var positions = trans.generateTransformedValuesCandle(entries, phaseY: _animator.phaseY);
                
                var lineHeight = valueFont.lineHeight;
                var yOffset: CGFloat = lineHeight + 5.0;
                
                for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * _animator.phaseX + CGFloat(minx))); j < count; j++)
                {
                    var x = positions[j].x;
                    var y = positions[j].y;
                    
                    if (!viewPortHandler.isInBoundsRight(x))
                    {
                        break;
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(x) || !viewPortHandler.isInBoundsY(y))
                    {
                        continue;
                    }
                    
                    var val = entries[j].high;
                    
                    
                    //K线上显示价格
                    //                    ChartUtils.drawText(context: context, text: formatter!.stringFromNumber(val)!, point: CGPoint(x: x, y: y - yOffset), align: .Center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor]);
                }
            }
        }
    }
    
    public override func drawExtras(#context: CGContext)
    {
    }
    
    private var _vertPtsBuffer = [CGPoint](count: 4, repeatedValue: CGPoint());
    private var _horzPtsBuffer = [CGPoint](count: 4, repeatedValue: CGPoint());
    //高亮状态界面
    public override func drawHighlighted(#context: CGContext, indices: [ChartHighlight])
    {
        var candleData = delegate!.candleStickChartRendererCandleData(self);
        if (candleData === nil)
        {
            return;
        }
        
        for (var i = 0; i < indices.count; i++)
        {
            var xIndex = indices[i].xIndex; // get the x-position
            
            var set = candleData.getDataSetByIndex(indices[i].dataSetIndex) as! CandleChartDataSet!;
            
            if (set === nil)
            {
                continue;
            }
            
            var e = set.entryForXIndex(xIndex) as! CandleChartDataEntry!;
            
            if (e === nil)
            {
                continue;
            }
            
            var trans = delegate!.candleStickChartRenderer(self, transformerForAxis: set.axisDependency);
            
            CGContextSetStrokeColorWithColor(context, set.highlightColor.CGColor);
            CGContextSetLineWidth(context, set.highlightLineWidth);
            if (set.highlightLineDashLengths != nil)
            {
                CGContextSetLineDash(context, set.highlightLineDashPhase, set.highlightLineDashLengths!, set.highlightLineDashLengths!.count);
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0);
            }
            
            var low = CGFloat(e.low) ;
            var high = CGFloat(e.high);
            var open = CGFloat(e.open);
            var close = CGFloat(e.close);
            var val = CGFloat(e.volume);
            var middle = (open + close)/2
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(low, forKey: "low")
            defaults.setObject(high, forKey: "high")
            defaults.setObject(open, forKey: "open")
            defaults.setObject(close, forKey: "close")
            defaults.setObject(val, forKey: "val")
            defaults.setObject(middle, forKey: "middle")
            
            var min = delegate!.candleStickChartRendererChartYMin(self);
            var max = delegate!.candleStickChartRendererChartYMax(self);
            
            _vertPtsBuffer[0] = CGPoint(x: CGFloat(xIndex) , y: CGFloat(max));
            _vertPtsBuffer[1] = CGPoint(x: CGFloat(xIndex) , y: CGFloat(min));
            _vertPtsBuffer[2] = CGPoint(x: CGFloat(xIndex) , y: CGFloat(max));
            _vertPtsBuffer[3] = CGPoint(x: CGFloat(xIndex) , y: CGFloat(min));
            
            _horzPtsBuffer[0] = CGPoint(x: CGFloat(0.0), y: middle);
            _horzPtsBuffer[1] = CGPoint(x: CGFloat(delegate!.candleStickChartRendererChartXMax(self)), y: middle);
            _horzPtsBuffer[2] = CGPoint(x: 0.0, y: middle);
            _horzPtsBuffer[3] = CGPoint(x: CGFloat(delegate!.candleStickChartRendererChartXMax(self)), y: middle);
            
            trans.pointValuesToPixel(&_vertPtsBuffer);
            trans.pointValuesToPixel(&_horzPtsBuffer);
        
//            print("Y2:\(_horzPtsBuffer[0].y)")
            defaults.setObject(_horzPtsBuffer[0].y, forKey: "horzY")
            
            // draw the vertical highlight lines
//            CGContextStrokeLineSegments(context, _vertPtsBuffer, 2);
            
            // draw the horizontal highlight lines
//            CGContextStrokeLineSegments(context, _horzPtsBuffer, 2);
            
            //水平线的价格
//            var linePrice = String(stringInterpolationSegment: round(middle*100)/100)
//            var _lineFont: UIFont! = UIFont(name: "HelveticaNeue", size: 12.0)
//            ChartUtils.drawText(context: context, text:linePrice, point: CGPoint(x:30, y:56+middle), align: .Center, attributes: [NSFontAttributeName: _lineFont, NSForegroundColorAttributeName: UIColor.grayColor()]);
//            
//            //开盘价
//            var openstr = "open:" as String
//            var horizontalPrice = String(stringInterpolationSegment: round(open*100)/100)
//            var openPrice = openstr + horizontalPrice
//            var _infoFont: UIFont! = UIFont(name: "HelveticaNeue", size: 12.0)
//            ChartUtils.drawText(context: context, text:openPrice, point: CGPoint(x:60, y:12), align: .Center, attributes: [NSFontAttributeName: _infoFont, NSForegroundColorAttributeName: UIColor.grayColor()]);
//            //收盘价
//            var closestr = "close:" as String
//            var closePricestr = String(stringInterpolationSegment: round(close*100)/100)
//            var closePrice = closestr + closePricestr
//            var _closeinfoFont: UIFont! = UIFont(name: "HelveticaNeue", size: 12.0)
//            ChartUtils.drawText(context: context, text:closePrice, point: CGPoint(x:120, y:12), align: .Center, attributes: [NSFontAttributeName: _closeinfoFont, NSForegroundColorAttributeName: UIColor.grayColor()]);
//            //最高价
//            var highstr = "high:" as String
//            var highPricestr = String(stringInterpolationSegment: round(high*100)/100)
//            var highPrice = highstr + highPricestr
//            var _highinfoFont: UIFont! = UIFont(name: "HelveticaNeue", size: 12.0)
//            ChartUtils.drawText(context: context, text:highPrice, point: CGPoint(x:180, y:12), align: .Center, attributes: [NSFontAttributeName: _highinfoFont, NSForegroundColorAttributeName: UIColor.grayColor()]);
//            //最低价
//            var lowstr = "low:" as String
//            var lowPricestr = String(stringInterpolationSegment: round(low*100)/100)
//            var lowPrice = lowstr + lowPricestr
//            var _lowinfoFont: UIFont! = UIFont(name: "HelveticaNeue", size: 12.0)
//            ChartUtils.drawText(context: context, text:lowPrice, point: CGPoint(x:240, y:12), align: .Center, attributes: [NSFontAttributeName: _lowinfoFont, NSForegroundColorAttributeName: UIColor.grayColor()]);
//            //成交量
//            var valstr = "val:" as String
//            var valPricestr = String(stringInterpolationSegment: round(val*100)/100)
//            var valPrice = valstr + valPricestr
//            var _valinfoFont: UIFont! = UIFont(name: "HelveticaNeue", size: 12.0)
//            ChartUtils.drawText(context: context, text:valPrice, point: CGPoint(x:320, y:12), align: .Center, attributes: [NSFontAttributeName: _valinfoFont, NSForegroundColorAttributeName: UIColor.grayColor()]);
            
        }
    }
}