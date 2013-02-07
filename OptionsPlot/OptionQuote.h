//
//  OptionQuote.h
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

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
@property (strong, nonatomic) NSString* underlyingTicker;
@property (strong, nonatomic) NSNumber* underlyingVolatility;
@property (strong, nonatomic) NSNumber* impliedVolatility;


-(id) initWithSymbol:(NSString*)symbol andAsk:(NSNumber*) ask andBid:(NSNumber*) bid atLastPrice:(NSNumber*) lastPrice withOpenInterest:(NSNumber*) openInt atStrikePrice:(NSNumber*) strikePrice ofType:(NSString*) type withVolume:(NSNumber*) volume andUnderlyingTicker:(NSString*) underlyingTicker;

@end