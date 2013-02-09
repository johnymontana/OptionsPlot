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
        
        
        NSArray* tickers = @[@"MSFT", @"AAPL"];
        
        NSArray *quotes = [optionQuoteDownload fetchQuotesFor:tickers];
        
        NSMutableDictionary *volSmile = [[NSMutableDictionary alloc] init];
        
        
        for (OptionQuote* quote in quotes)
        {
            [quote calcBlackScholesPrice];
            [quote calcImpliedVolatility];
            if ([quote.type isEqual:@"C"])
            {
                [volSmile setObject:quote.impliedVolatility forKey:quote.strikePrice];
            }
            NSLog(@"%@", [quote description]);
            
            
          //  NSLog(@"BS Price: %@", quote.blackScholesPrice);
        }
        
        NSLog(@"%@", volSmile);
        
        for (id key in volSmile)
        {
            //NSLog
        }
        
      //  NSLog(@"%@",[optionQuoteDownload calcUnderlyingVolatility:@"MSFT"]);
        
    }
    return 0;
}

