//
//  optionQuoteDownload.m
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//
//
// This class handles YQL query for option quote fetching and calculates historic volatility from stock quotes

#import "OptionQuoteDownload.h"
#import "OptionQuote.h"

@implementation OptionQuoteDownload

// adapted from: http://tech.element77.com/2012/02/fetching-stock-data-from-yahoo-for-ios.html

// TODO: expiration date issue
// for now 2013-03-15 is hardcoded for expiration

#define QUOTE_QUERY_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.options%20where%20symbol%20in%20("
#define QUOTE_QUERY_SUFFIX @")%20and%20expiration%3D%222013-03%22&format=json&diagnostics=false&env=http%3A%2F%2Fdatatables.org%2Falltables.env&callback="

+ (NSArray *)fetchQuotesFor:(NSArray *)tickers
{
    
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    // TODO: REFACTOR THIS:
    NSString* assetTicker = tickers[0];
    
    if (tickers && [tickers count] > 0) {
        NSMutableString *query = [[NSMutableString alloc] init]; 
        [query appendString:QUOTE_QUERY_PREFIX];
        for (int i = 0; i < [tickers count]; i++) {
            NSString *ticker = [tickers objectAtIndex:i];
            [query appendFormat:@"%%22%@%%22", ticker];
            if (i != [tickers count] - 1) [query appendString:@"%2C"];
        }
        [query appendString:QUOTE_QUERY_SUFFIX];
         NSLog(@"Query: %@", query);
        NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
        if (error)
        {
            
            NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
            NSLog(@"Yahoo! Finance quotes not available. Try again later. Terminating...");
            exit(1);
        }
        
        NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
        NSArray *quoteEntries = [results valueForKeyPath:@"query.results.optionsChain.option"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
        NSString* expirationDate = [results valueForKeyPath:@"query.results.optionsChain.expiration"];
        
        NSDate* exprDate = [dateFormatter dateFromString:expirationDate];
        
        // quotes = [[NSMutableDictionary alloc] initWithCapacity:[quoteEntries count]];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSNumber* volatility = [OptionQuoteDownload calcUnderlyingVolatility:assetTicker];
        NSNumber* spot = [OptionQuoteDownload getCurrentPrice:assetTicker];
        
        for (NSDictionary *quoteEntry in quoteEntries) {
            
            NSLog(@"Expiration date: %@", expirationDate);
            
            
            // NSLog(@"Strike: %@", quoteEntry[@"strikePrice"]);
            for (id key in quoteEntry)
            {
                NSLog(@"QuoteEntry: %@:%@", key, quoteEntry[key]);
            
            }
            
            if ([quoteEntry[@"lastPrice"] isKindOfClass:[NSString class]]) 
            {
                [quotes addObject:[[OptionQuote alloc] initWithSymbol:quoteEntry[@"symbol"]
                                                               andAsk:[formatter numberFromString:quoteEntry[@"ask"]]
                                                               andBid:[formatter numberFromString:quoteEntry[@"bid"]]
                                                          atLastPrice:[formatter numberFromString:quoteEntry[@"lastPrice"]]
                                                     withOpenInterest:[formatter numberFromString:quoteEntry[@"openInt"]]
                                                        atStrikePrice:[formatter numberFromString:quoteEntry[@"strikePrice"]]
                                                               ofType:quoteEntry[@"type"]
                                                       withExpiration:exprDate
                                                           withVolume:[formatter numberFromString:quoteEntry[@"vol"]]
                                                  andUnderlyingTicker:assetTicker
                                                       withVolatility:volatility
                                                         andSpotPrice:spot]];
            }
            
            //[quotes setValue:[quoteEntry valueForKey:@"lastPrice"] forKey:[quoteEntry valueForKey:@"strikePrice"]];
        }
    }
    return quotes;
}

// standardDeviationOf: adapted from http://stackoverflow.com/questions/4889486/obj-c-calculate-the-standard-deviation-of-an-nsarray-of-nsnumber-objects

+ (NSNumber *)meanOf:(NSArray *)array
{
    double runningTotal = 0.0;
    
    for(NSNumber *number in array)
    {
        runningTotal += [number doubleValue];
    }
    
    return [NSNumber numberWithDouble:(runningTotal / [array count])];
}

+ (NSNumber *)standardDeviationOf:(NSArray *)array
{
    if(![array count]) return nil;
    
    double mean = [[self meanOf:array] doubleValue];
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in array)
    {
        double valueOfNumber = [number doubleValue];
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return [NSNumber numberWithDouble:sqrt(sumOfSquaredDifferences / [array count])];
}

//http://query.yahooapis.com/v1/public/yql?q=select%20Adj_Close%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22YHOO%22%20and%20startDate%20%3D%20%222013-01-01%22%20and%20endDate%20%3D%20%222013-02-06%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=
#define HIST_QUOTES_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20Adj_Close%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22"
#define HIST_QUOTES_SUFFIX @"%22%20and%20startDate%20%3D%20%222013-01-01%22%20and%20endDate%20%3D%20%222013-02-06%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
// TODO: fix hardcoded dates

+(NSNumber*)calcUnderlyingVolatility:(NSString *)ticker
{
    
    //select Adj_Close from yahoo.finance.historicaldata where symbol = "YHOO" and startDate = "2009-09-11" and endDate = "2010-03-10"
    
    
    NSMutableArray* histQuotes = [[NSMutableArray alloc] init];
    NSMutableString* query = [[NSMutableString alloc] init];
    
    [query appendString:HIST_QUOTES_PREFIX];
    //[query appendFormat:@"%%22%@%%22", ticker];
    [query appendFormat:@"%@", ticker];
    [query appendString:HIST_QUOTES_SUFFIX];
    
    NSLog(@"Query: %@", query);
    
    NSData* jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error ] : nil;
    
    if (error)
    {
        NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
        NSLog(@"Yahoo! Finance quotes not available. Try again later. Terminating...");
        exit(1);
    }
    NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    NSArray* quoteEntries = [results valueForKeyPath:@"query.results.quote"]; // see what we get
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    if ([quoteEntries isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *quoteEntry in quoteEntries)
        {
            
            [histQuotes addObject:[formatter numberFromString:quoteEntry[@"Adj_Close"]]];
        }
        
        NSLog(@"%@", histQuotes);
        double stdDev = [[self standardDeviationOf:histQuotes] doubleValue];
        double normalizeTerm = sqrt(21)*.01;
        return [NSNumber numberWithDouble:(stdDev*normalizeTerm)];

    }
       
    NSLog(@"Historical volatility not available. Terminating...");
    exit(1);
}


// http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%3D%22AAPL%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=
#define CURR_QUOTE_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%3D%22"
#define CURR_QUOTE_SUFFIX @"%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="


+(NSNumber*)getCurrentPrice:(NSString *)ticker
{
    
    
   // NSMutableArray* histQuotes = [[NSMutableArray alloc] init];
    NSMutableString* query = [[NSMutableString alloc] init];
    
    [query appendString:CURR_QUOTE_PREFIX];
    //[query appendFormat:@"%%22%@%%22", ticker];
    [query appendFormat:@"%@", ticker];
    [query appendString:CURR_QUOTE_SUFFIX];
    
    NSLog(@"Query: %@", query);
    
    NSData* jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error ] : nil;
    
    if (error)
    {
        
        NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
        NSLog(@"Yahoo! Finance quotes not available, try again later. Terminating...");
        exit(1);
    }
    
    NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    NSString* lastTradePriceOnly = [results valueForKeyPath:@"query.results.quote.LastTradePriceOnly"]; // see what we get
    NSLog(@"Last Trade price: %@", lastTradePriceOnly);
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if ([lastTradePriceOnly isKindOfClass:[NSString class]])
    {
        return [formatter numberFromString:lastTradePriceOnly];
    }
    else
    {
        NSLog(@"Yahoo! Finance quotes not available. Please try again later. Terminating...");
        exit(1);
    }
    
}




@end
