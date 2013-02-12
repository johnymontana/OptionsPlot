//
//  OptionQuote_Test.m
//  OptionsPlot
//
//  Created by lyonwj on 2/12/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import "OptionQuote_Test.h"
#import "OptionQuote.h"
#import "fin_recipes.h"

@implementation OptionQuote_Test

-(void)setUp
{
    
    [super setUp];
    
    quote = [[OptionQuote alloc] initWithSymbol:@"AAPL130308P0015000"
                                         andAsk:[NSNumber numberWithDouble:1.2]
                                         andBid:[NSNumber numberWithDouble:3.2]
                                    atLastPrice:[NSNumber numberWithDouble:5.5]
                               withOpenInterest:[NSNumber numberWithInt:3331]
                                  atStrikePrice:[NSNumber numberWithDouble:15]
                                         ofType:@"C"
                                 withExpiration:[NSDate dateWithNaturalLanguageString:@"03-14-2013"]
                                     withVolume:[NSNumber numberWithInt:55555]
                            andUnderlyingTicker:@"AAPL"
                                 withVolatility:[NSNumber numberWithDouble:0.22]
                                   andSpotPrice:[NSNumber numberWithInt:20.]];

    
    quote1 = [[OptionQuote alloc] initWithSymbol:@"AAPL130308P00510000"
                                          andAsk:[NSNumber numberWithDouble:1.2]
                                          andBid:[NSNumber numberWithDouble:3.2]
                                     atLastPrice:[NSNumber numberWithDouble:5.5]
                                withOpenInterest:[NSNumber numberWithInt:3331]
                                   atStrikePrice:[NSNumber numberWithDouble:19]
                                          ofType:@"C"
                                  withExpiration:[NSDate dateWithNaturalLanguageString:@"03-14-2013"]
                                      withVolume:[NSNumber numberWithInt:55555]
                             andUnderlyingTicker:@"AAPL"
                                  withVolatility:[NSNumber numberWithDouble:1.1]
                                    andSpotPrice:[NSNumber numberWithInt:20.]];
    
    quote2 = [[OptionQuote alloc] initWithSymbol:@"AAPL130308P00510000"
                                          andAsk:[NSNumber numberWithDouble:1.2]
                                          andBid:[NSNumber numberWithDouble:3.2]
                                     atLastPrice:[NSNumber numberWithDouble:5.5]
                                withOpenInterest:[NSNumber numberWithInt:3331]
                                   atStrikePrice:[NSNumber numberWithDouble:21]
                                          ofType:@"C"
                                  withExpiration:[NSDate dateWithNaturalLanguageString:@"03-14-2013"]
                                      withVolume:[NSNumber numberWithInt:55555]
                             andUnderlyingTicker:@"AAPL"
                                  withVolatility:[NSNumber numberWithDouble:1.2]
                                    andSpotPrice:[NSNumber numberWithInt:20.]];

    quote3 = [[OptionQuote alloc] initWithSymbol:@"AAPL130308P00510000"
                                          andAsk:[NSNumber numberWithDouble:1.2]
                                          andBid:[NSNumber numberWithDouble:3.2]
                                     atLastPrice:[NSNumber numberWithDouble:5.5]
                                withOpenInterest:[NSNumber numberWithInt:3331]
                                   atStrikePrice:[NSNumber numberWithDouble:18]
                                          ofType:@"C"
                                  withExpiration:[NSDate dateWithNaturalLanguageString:@"03-14-2013"]
                                      withVolume:[NSNumber numberWithInt:55555]
                             andUnderlyingTicker:@"AAPL"
                                  withVolatility:[NSNumber numberWithDouble:1.3]
                                    andSpotPrice:[NSNumber numberWithInt:20.]];

    arrayOfQuotes=@[quote, quote1, quote2, quote3];
    
    for (OptionQuote* quoteArrayItem in arrayOfQuotes)
    {
        [quoteArrayItem calcBlackScholesPrice];
        [quoteArrayItem calcImpliedVolatility];
    }
    
    quote.impliedVolatility = [NSNumber numberWithDouble:0.1];
    quote1.impliedVolatility = [NSNumber numberWithDouble:0.2];
    quote2.impliedVolatility = [NSNumber numberWithDouble:0.3];
    quote3.impliedVolatility = [NSNumber numberWithDouble:0.4];
}

-(void)testThatOptionQuoteExists
{
       STAssertNotNil(quote, @"create new OptionQuote instance");
}


-(void)testBlackScholesPrice
{
    // call [quote calcBlackScholesPrice] and compare quote.blackScholoesPrice
    
    double callPriceVerified = 5.019;   // calculated using http://www.soarcorp.com/black_scholes_calculator.jsp
    double spot = 20.;
    double strike = 15.;
    double r = 0.0025;
    double sigma = 0.02;
    double time = 0.5;
    
    double callPrice = option_price_call_black_scholes(spot, strike, r, sigma, time);
    
    STAssertEqualsWithAccuracy(callPrice, callPriceVerified, 0.001, @"Fin recipes C++ library BS call price calc");
    
}

-(void)testImpliedVolatilityCalc
{
    OptionQuote* myQuote = [[OptionQuote alloc] initWithSymbol:@"AAPL130308P00510000"
                                          andAsk:[NSNumber numberWithDouble:1.2]
                                          andBid:[NSNumber numberWithDouble:3.2]
                                     atLastPrice:[NSNumber numberWithDouble:2]
                                withOpenInterest:[NSNumber numberWithInt:3331]
                                   atStrikePrice:[NSNumber numberWithDouble:19]
                                          ofType:@"C"
                                  withExpiration:[NSDate dateWithNaturalLanguageString:@"03-14-2014"]
                                      withVolume:[NSNumber numberWithInt:55555]
                             andUnderlyingTicker:@"AAPL"
                                  withVolatility:[NSNumber numberWithDouble:1.1]
                                    andSpotPrice:[NSNumber numberWithInt:20.]];
    
    [myQuote calcImpliedVolatility];
    
    double verifiedIV = 0.17885;            // calculated using http://www.quantwolf.com/calculators/impliedvolatilitycalc.html
    
    STAssertEqualsWithAccuracy(verifiedIV, [[myQuote impliedVolatility] doubleValue], 0.01, @"Confirm implied volatility calc and set correctly");   // this level of accuracy is probably not acceptable

}

-(void)testGetImpliedVolatilityInTheMoney
{
    NSNumber* inTheMoneyVol = [NSNumber numberWithDouble:0.2];      // OptionQuote least in the  money: quote2
    NSNumber* impliedVol = [OptionQuote getImpliedVolatilityInTheMoney:arrayOfQuotes];
    
    STAssertEqualObjects(inTheMoneyVol, impliedVol, @"Implied volatility in the money should be 1.1 (Spot: 20, Strike: 19)");
}

-(void)tearDown
{
    [super tearDown];
    quote=nil;
    quote = nil;
    quote1 = nil;
    quote2 = nil;
    quote3 = nil;
}
@end
