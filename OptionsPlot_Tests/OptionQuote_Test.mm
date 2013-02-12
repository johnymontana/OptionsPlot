//
//  OptionQuote_Test.m
//  OptionsPlot
//
//  Created by lyonwj on 2/12/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import "OptionQuote_Test.h"
#import "OptionQuote.h"

@implementation OptionQuote_Test

-(void)testThatOptionQuoteExists
{
    OptionQuote* quote = [[OptionQuote alloc] initWithSymbol:@"AAPL132005" andAsk:[NSNumber numberWithDouble:1.2] andBid:[NSNumber numberWithDouble:3.2] atLastPrice:[NSNumber numberWithDouble:5.5] withOpenInterest:[NSNumber numberWithInt:3331] atStrikePrice:[NSNumber numberWithDouble:33] ofType:@"C" withExpiration:[NSDate date] withVolume:[NSNumber numberWithInt:55555] andUnderlyingTicker:@"AAPL" withVolatility:[NSNumber numberWithDouble:0.22] andSpotPrice:[NSNumber numberWithInt:33.54]];
    STAssertNotNil(quote, @"create new OptionQuote instance");
}
@end
