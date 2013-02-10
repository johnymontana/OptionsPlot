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
    // TODO: return NSString description of OptionQuote
    return [NSString stringWithFormat:@"%@, spot:%@: %@ at %@, lastOptPrice: %@, bsPrice: %@, bsPrice_IV: %@, expr:%@ %@, sigma= %@, IV=%@", self.underlyingTicker, self.spotPrice, self.symbol, self.strikePrice, self.lastPrice, self.blackScholesPrice, self.blackScholesPrice_IV, [self.expiration descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil], self.type, self.underlyingVolatility, self.impliedVolatility];
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
        
        if (self.impliedVolatility==[NSNumber numberWithDouble:0.0])
        {
            self.impliedVolatility = [NSNumber numberWithDouble:option_price_implied_volatility_call_black_scholes_newton(spot, strike, risk_free_rate, time, optionsPrice)];
        }
    }
    // cannot find implementation of option_price_implied_volatility_put** 
 //   if ([self.type isEqual:@"P"])
 //   {
 //       self.impliedVolatility = [NSNumber numberWithDouble:option_price_implied_volatility_put_black_scholes_bisections(spot, strike, risk_free_rate, time, optionsPrice)];
//    }
}


-(void) calcBlackScholesPrice   // this method sets self.blackScholesPrice using calculated historic volatility
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
    for (OptionQuote* quote in optionQuotes)
    {
        if ([quote.spotPrice doubleValue]>[quote.strikePrice doubleValue] && [quote.spotPrice doubleValue] < ([quote.strikePrice doubleValue]*1.05) && quote.impliedVolatility && [quote.impliedVolatility isNotEqualTo:[NSNumber numberWithDouble:0.0]]) // if quote is just in the money and it's IV is not null or zero, then let's use it's IV
        {
            return quote.impliedVolatility;
        }
    }
    
    NSLog(@"No valid implied volatility found, returning zero");
    return [NSNumber numberWithDouble:0.0];
}

@end
