//
//  CandleStickChartView.swift
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

/// Financial chart type that draws candle-sticks.
public class CandleStickChartView: BarLineChartViewBase, CandleStickChartRendererDelegate
{
    internal override func initialize()
    {
        super.initialize();
        
        //画K线的方法
        renderer = CandleStickChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler);
        _chartXMin = -0.5;//设置K线从哪里开始画起,距离左边的距离

    }

    internal override func calcMinMax()
    {
        super.calcMinMax();

//        _chartXMax += 0.5;//设置K线从哪里结束画起,距离右边的距离
         _chartXMax += 1;
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin));
    }
    
    // MARK: - CandleStickChartRendererDelegate
    
    public func candleStickChartRendererCandleData(renderer: CandleStickChartRenderer) -> CandleChartData!
    {
        return _data as! CandleChartData!;
    }
    
    public func candleStickChartRenderer(renderer: CandleStickChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return self.getTransformer(which);
    }
    
    public func candleStickChartDefaultRendererValueFormatter(renderer: CandleStickChartRenderer) -> NSNumberFormatter!
    {
        return self.valueFormatter;
    }
    
    public func candleStickChartRendererChartYMax(renderer: CandleStickChartRenderer) -> Float
    {
        return self.chartYMax;
    }
    
    public func candleStickChartRendererChartYMin(renderer: CandleStickChartRenderer) -> Float
    {
        return self.chartYMin;
    }
    
    public func candleStickChartRendererChartXMax(renderer: CandleStickChartRenderer) -> Float
    {
        return self.chartXMax;
    }
    
    public func candleStickChartRendererChartXMin(renderer: CandleStickChartRenderer) -> Float
    {
        return self.chartXMin;
    }
    
    public func candleStickChartRendererMaxVisibleValueCount(renderer: CandleStickChartRenderer) -> Int
    {
        return self.maxVisibleValueCount;
    }
}