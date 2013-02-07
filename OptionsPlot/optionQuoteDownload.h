//
//  optionQuoteDownload.h
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface optionQuoteDownload : NSObject

+(NSArray*) fetchQuotesFor:(NSArray*) tickers;


+(NSNumber*) calcUnderlyingVolatility:(NSString*) ticker;

@end
