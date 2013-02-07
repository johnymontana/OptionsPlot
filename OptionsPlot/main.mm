//
//  main.m
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "optionQuoteDownload.h"
#import "OptionQuote.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSArray* tickers = @[@"AAPL"];
        
        NSArray *quotes = [optionQuoteDownload fetchQuotesFor:tickers];
        
        for (OptionQuote* quote in quotes)
        {
            NSLog([quote description]);
        }
        
        NSLog(@"%@",[optionQuoteDownload calcUnderlyingVolatility:@"MSFT"]);
        
    }
    return 0;
}

