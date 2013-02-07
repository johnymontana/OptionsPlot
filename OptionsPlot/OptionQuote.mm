//
//  OptionQuote.m
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import "OptionQuote.h"

@implementation OptionQuote

-(id) initWithSymbol:(NSString*)symbol andAsk:(NSNumber*) ask andBid:(NSNumber*) bid atLastPrice:(NSNumber*) lastPrice withOpenInterest:(NSNumber*) openInt atStrikePrice:(NSNumber*) strikePrice ofType:(NSString*) type withVolume:(NSNumber*) volume andUnderlyingTicker:(NSString*) underlyingTicker
{
    self = [super init];
    
    if (self)
    {
        self.ask = ask;
        self.bid = bid;
        self.lastPrice = lastPrice;
        self.openInt = openInt;
        self.strikePrice = strikePrice;
        self.symbol = symbol;
        self.type = type;
        self.volume = volume;
        self.underlyingTicker = underlyingTicker;
    }
    
    return self;
}

-(NSString*)description
{
    // TODO: return NSString description of OptionQuote
    return [NSString stringWithFormat:@"%@: %@ at %@, %@, %@", self.underlyingTicker, self.symbol, self.strikePrice, self.lastPrice, self.type];
}

-(NSNumber*)underlyingVolatility
{
    // TODO: calulate volatility of
    
}
@end
