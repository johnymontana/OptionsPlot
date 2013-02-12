//
//  optionQuoteDownload.h
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//
// This class handles YQL query for option quote fetching and calculates historic volatility from stock quotes

#import <Foundation/Foundation.h>

@interface OptionQuoteDownload : NSObject

+(NSArray*) fetchQuotesFor:(NSArray*) tickers;


+(NSNumber*) calcUnderlyingVolatility:(NSString*) ticker;

@end
