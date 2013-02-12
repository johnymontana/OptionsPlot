//
//  OptionQuote.h
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//
// This class holds all data for a specific Option quote
// and has functionality to calc black scholoes price and implied volatilities

#import <Foundation/Foundation.h>

@interface OptionQuote : NSObject

// TODO: what data types should these things be and how to cast them correctly?!?
@property (strong, nonatomic) NSNumber* ask;
@property (strong, nonatomic) NSNumber* bid;
@property (strong, nonatomic) NSNumber* lastPrice;
@property (strong, nonatomic) NSNumber* openInt;
@property (strong, nonatomic) NSNumber* strikePrice;
@property (strong, nonatomic) NSString* symbol;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSNumber* volume;
@property (strong, nonatomic) NSString* underlyingTicker;       // collection should be used for all underlying data, should point to an UnderLying asset object
@property (strong, nonatomic) NSNumber* underlyingVolatility;
@property (strong, nonatomic) NSNumber* impliedVolatility;
@property (strong, nonatomic) NSNumber* blackScholesPrice;      // computed using historic volatility
@property (strong, nonatomic) NSNumber* blackScholesPrice_IV;   // computed using at the money IV
@property (strong, nonatomic) NSNumber* spotPrice;
@property (strong, nonatomic) NSDate* expiration;


-(id) initWithSymbol:(NSString*)symbol                          // default init
              andAsk:(NSNumber*) ask
              andBid:(NSNumber*) bid
         atLastPrice:(NSNumber*) lastPrice
    withOpenInterest:(NSNumber*) openInt
       atStrikePrice:(NSNumber*) strikePrice
              ofType:(NSString*) type
      withExpiration:(NSDate*) expiration
          withVolume:(NSNumber*) volume
 andUnderlyingTicker:(NSString*) underlyingTicker
      withVolatility:(NSNumber*) volatility
        andSpotPrice:(NSNumber*) spot;

// these are set up to be called explicitly from main() for profiling
-(void) calcBlackScholesPrice;                                  // set Black-Scholes price

-(void) calcImpliedVolatility;                                  // set IV

+(NSNumber*) getImpliedVolatilityInTheMoney:(NSArray*)optionQuotes;

-(void) calcBlackScholesPriceUsingVolatility:(NSNumber*)volatility; // set BS price using a specified IV

@end