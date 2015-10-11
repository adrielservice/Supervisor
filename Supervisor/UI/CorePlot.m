//
//  CorePlot.m
//  HTCC Sample
//
//  Created by Arkady on 3/28/14.
//  Copyright (c) 2014 Genesys. All rights reserved.
//

#import "CorePlot.h"
#import "NSArray+HTCC.h"

@implementation CorePlot
{
    CPTGraphHostingView *defaultLayerHostingView;
    CPTGraph *graph;
    NSString *title;
}

+(instancetype)createWithTitle:(NSString *)title
{
    CorePlot *cp = [[self alloc] init];
    cp->title = title;
    return cp;
}

- (void)setPlotData:(NSArray *)data
{
    if([data isKindOfClass:[NSArray class]] && [data areAllArrayElementsMembersOfClass:[NSDictionary class]])
        _plotData = data;
}

-(void)killGraph
{
    [[CPTAnimation sharedInstance] removeAllAnimationOperations];
    
    // Remove the CPTLayerHostingView
    if ( defaultLayerHostingView ) {
        [defaultLayerHostingView removeFromSuperview];
        
        defaultLayerHostingView.hostedGraph = nil;
        defaultLayerHostingView = nil;
    }    
    graph = nil;
}


-(void)renderInView:(UIView *)hostingView animated:(BOOL)animated
{
    [self killGraph];
    
    defaultLayerHostingView = [[CPTGraphHostingView alloc] initWithFrame:hostingView.bounds];
    
    defaultLayerHostingView.collapsesLayers = NO;
    [defaultLayerHostingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [defaultLayerHostingView setAutoresizesSubviews:YES];
    
    [hostingView addSubview:defaultLayerHostingView];
    [self renderInLayer:defaultLayerHostingView animated:animated];
}

-(void)setTitleDefaultsForGraph
{
    CGRect bounds = defaultLayerHostingView.bounds;
    graph.title = title;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor darkGrayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = round( bounds.size.height / CPTFloat(20.0) );
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CPTPointMake( 0.0, textStyle.fontSize * CPTFloat(1.5) );
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
}

-(void)setPaddingDefaultsForGraph
{
    CGRect bounds = defaultLayerHostingView.bounds;
    CGFloat boundsPadding = round( bounds.size.width / CPTFloat(20.0) ); // Ensure that padding falls on an integral pixel
    
    graph.paddingLeft = boundsPadding;
    
    if ( graph.titleDisplacement.y > 0.0 ) {
        graph.paddingTop = graph.titleTextStyle.fontSize * 2.0;
    }
    else {
        graph.paddingTop = boundsPadding;
    }
    
    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;
}


-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView animated:(BOOL)animated
{
    CGRect bounds = layerHostingView.bounds;

    
    graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    defaultLayerHostingView.hostedGraph = graph;
    
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    [self setTitleDefaultsForGraph];
    [self setPaddingDefaultsForGraph];
    
    graph.plotAreaFrame.masksToBorder = NO;
    graph.axisSet                     = nil;
    
    // Overlay gradient for pie chart
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.0];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.3] atPosition:0.9];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.7] atPosition:1.0];
    
    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN(0.7 * (layerHostingView.frame.size.height - 2 * graph.paddingLeft) / 2.0,
                             0.7 * (layerHostingView.frame.size.width - 2 * graph.paddingTop) / 2.0);
    piePlot.identifier     = title;
    piePlot.startAngle     = M_PI_4;
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    piePlot.overlayFill    = [CPTFill fillWithGradient:overlayGradient];
    
    piePlot.labelRotationRelativeToRadius = YES;
    piePlot.labelRotation                 = -M_PI_2;
    piePlot.labelOffset                   = -50.0;
    
    piePlot.delegate = self;
    [graph addPlot:piePlot];
    
    // Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfColumns = 1;
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    
    theLegend.entryFill            = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    theLegend.entryBorderLineStyle = [CPTLineStyle lineStyle];
    theLegend.entryCornerRadius    = CPTFloat(3.0);
    theLegend.entryPaddingLeft     = CPTFloat(3.0);
    theLegend.entryPaddingTop      = CPTFloat(3.0);
    theLegend.entryPaddingRight    = CPTFloat(3.0);
    theLegend.entryPaddingBottom   = CPTFloat(3.0);
    
    theLegend.cornerRadius = 5.0;
    theLegend.delegate     = self;
    
    graph.legend = theLegend;
    
    graph.legendAnchor       = CPTRectAnchorRight;
    graph.legendDisplacement = CGPointMake(-graph.paddingRight - 10.0, 0.0);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;
    
    if ( !whiteText ) {
        whiteText       = [[CPTMutableTextStyle alloc] init];
        whiteText.color = [CPTColor whiteColor];
    }
    
    CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:[_plotData[index][@"value"] stringValue] style:whiteText];
    return newLayer;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return _plotData.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;
    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        num = _plotData[index][@"value"];
    }
    else {
        num = @(index);
    }
    return num;
}

-(NSAttributedString *)attributedLegendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
//    UIColor *sliceColor = [CPTPieChart defaultPieSliceColorForIndex:index].uiColor;
    
    NSMutableAttributedString *legendTitle = [[NSMutableAttributedString alloc] initWithString:_plotData[index][@"statistic"]];
//    if ( &NSForegroundColorAttributeName != NULL ) {
//        [legendTitle addAttribute:NSForegroundColorAttributeName
//                      value:sliceColor
//                      range:NSMakeRange(4, 5)];
//    }
    return legendTitle;
}



@end
