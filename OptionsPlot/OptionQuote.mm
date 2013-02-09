//
//  OptionQuote.m
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import "OptionQuote.h"
#import "fin_recipes.h"
//#import "black_scholes_call.mm"
//#import "black_scholes_put.cc"


#define RISK_FREE_RATE 0.25
@implementation OptionQuote

-(id) initWithSymbol:(NSString*)symbol
              andAsk:(NSNumber*) ask
              andBid:(NSNumber*) bid
         atLastPrice:(NSNumber*) lastPrice
    withOpenInterest:(NSNumber*) openInt
       atStrikePrice:(NSNumber*) strikePrice
              ofType:(NSString*) type
      withExpiration:(NSDate*)expiration
          withVolume:(NSNumber*) volume
 andUnderlyingTicker:(NSString*) underlyingTicker
      withVolatility:(NSNumber *)volatility
        andSpotPrice:(NSNumber *)spot
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
        self.underlyingVolatility = volatility;
        self.spotPrice = spot;
        self.expiration = expiration;
    }
    
    return self;
}

-(NSString*)description
{
    // TODO: return NSString description of OptionQuote
    return [NSString stringWithFormat:@"%@, spot:%@: %@ at %@, lastOptPrice: %@, bsPrice: %@, expr:%@ %@, sigma= %@, IV=%@", self.underlyingTicker, self.spotPrice, self.symbol, self.strikePrice, self.lastPrice, self.blackScholesPrice, [self.expiration descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil], self.type, self.underlyingVolatility, self.impliedVolatility];
}

-(NSNumber*)underlyingVolatility
{
    // TODO: calulate volatility of
    return _underlyingVolatility;
}

-(void) calcImpliedVolatility
{
    double risk_free_rate = RISK_FREE_RATE;
    double time = 0.1;
    double spot = [self.spotPrice doubleValue];
    double strike = [self.strikePrice doubleValue];
    double optionsPrice = [self.lastPrice doubleValue];
    
    if ([self.type isEqual:@"C"])
    {
        self.impliedVolatility = [NSNumber numberWithDouble:option_price_implied_volatility_call_black_scholes_bisections(spot, strike, risk_free_rate, time, optionsPrice)];
    }
}

-(void) calcBlackScholesPrice
{
    double risk_free_rate = RISK_FREE_RATE;
    double time = 0.1;
    double spot = [self.spotPrice doubleValue];
    double strike = [self.strikePrice doubleValue];
    double vol = [self.underlyingVolatility doubleValue];
    
    
    if ([self.type isEqual:@"C"])
    {
        self.blackScholesPrice = [NSNumber numberWithDouble:option_price_call_black_scholes(spot, strike, risk_free_rate, vol, time)];
        
    }
    
    else if ([self.type isEqual:@"P"])
    {
        self.blackScholesPrice = [NSNumber numberWithDouble:option_price_put_black_scholes(spot, strike, risk_free_rate, vol, time)];
    }
}

@end
