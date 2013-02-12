//
//  OptionQuote.m
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import "OptionQuote.h"
#import "fin_recipes.h"



#define RISK_FREE_RATE 0.0025
#define SECONDS_IN_YEAR 31536000.0

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
    return [NSString stringWithFormat:@"%@, spot:%@: %@ at %@, lastOptPrice: %@, bsPrice: %@, bsPrice_IV: %@, expr:%@ %@, sigma= %@, IV=%@", self.underlyingTicker, self.spotPrice, self.symbol, self.strikePrice, self.lastPrice, self.blackScholesPrice, self.blackScholesPrice_IV, [self.expiration descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil], self.type, self.underlyingVolatility, self.impliedVolatility];
}

-(NSNumber*)underlyingVolatility
{
    // TODO: lazy instantiation? -> No, calc explicityly for profiling
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
        self.impliedVolatility = [NSNumber numberWithDouble:option_price_implied_volatility_call_black_scholes_newton(spot, strike, risk_free_rate, time, optionsPrice)];
        
        if ([self.impliedVolatility isEqualToNumber:[NSNumber numberWithDouble:-99e10]])
        {
            self.impliedVolatility = [NSNumber numberWithDouble:option_price_implied_volatility_call_black_scholes_bisections(spot, strike, risk_free_rate, time, optionsPrice)];
        }
    }
    // cannot find implementation of option_price_implied_volatility_put** 
 //   if ([self.type isEqual:@"P"])
 //   {
 //       self.impliedVolatility = [NSNumber numberWithDouble:option_price_implied_volatility_put_black_scholes_bisections(spot, strike, risk_free_rate, time, optionsPrice)];
//    }
}


-(void) calcBlackScholesPrice   // sets self.blackScholesPrice using calculated historic volatility
{
    double risk_free_rate = RISK_FREE_RATE;
    double time = [self.expiration timeIntervalSinceDate:[NSDate date]] / SECONDS_IN_YEAR; // not quite right, should be number of trading days. Could use NSCalendar to compute trading days
   // NSLog(@"time argument: %f:", time);
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

-(void) calcBlackScholesPriceUsingVolatility:(NSNumber*) volatility
{
    // TODO: set self.blackScholesPrice_IV using volatility
    double risk_free_rate = RISK_FREE_RATE;
    double time = [self.expiration timeIntervalSinceDate:[NSDate date]] / SECONDS_IN_YEAR; // not quite right, should be number of trading days. Could use NSCalendar to compute trading days
    // NSLog(@"time argument: %f:", time);
    double spot = [self.spotPrice doubleValue];
    double strike = [self.strikePrice doubleValue];
    double vol = [volatility doubleValue];
    
    if ([self.type isEqual:@"C"])
    {
        self.blackScholesPrice_IV = [NSNumber numberWithDouble:option_price_call_black_scholes(spot, strike, risk_free_rate, vol, time)];
    }
    
    else if ([self.type isEqual:@"P"])
    {
        self.blackScholesPrice_IV = [NSNumber numberWithDouble:option_price_put_black_scholes(spot, strike, risk_free_rate, vol, time)];
    }

    
}


+(NSNumber*) getImpliedVolatilityInTheMoney:(NSArray *)optionQuotes
{
    // Find OptionQuote in the money and return its implied volatility
    // This assumes calls only since no puts have IV at this point, need to deal with puts as well
    // also assumes all OptionQuotes have same underlying asset
    
    OptionQuote* firstQuote = optionQuotes[0];
    NSNumber* targetStrike = [NSNumber numberWithInt:[firstQuote.spotPrice intValue]];
    
    while ([targetStrike isGreaterThan:[NSNumber numberWithInt:0]])
    {
        
        for (OptionQuote* quote in optionQuotes)
        {
            if ([quote.strikePrice isEqualToNumber:targetStrike])
            {
                return quote.impliedVolatility;
            }
        }
        
        targetStrike = [NSNumber numberWithInt:([targetStrike intValue]-1)]; // no OptionQuote found at this strike, lower target strike price
    
        
    }
   
    
    NSLog(@"No valid implied volatility found, returning zero");
    return [NSNumber numberWithDouble:0.0];
}

@end
