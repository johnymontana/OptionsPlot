//
//  optionQuoteDownload.m
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import "optionQuoteDownload.h"
#import "OptionQuote.h"

@implementation optionQuoteDownload

//select option
//from yahoo.finance.options
//where symbol = "AAPL"
//and expiration = "2011-07"
//and option.symbol = "AAPL110716C00155000"

// http://stackoverflow.com/questions/6442737/get-financial-option-data-with-yql

//#define QUOTE_QUERY_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20symbol%2C%20BidRealtime%20from%20yahoo.finance.quotes%20where%20symbol%20in%20("
//#define QUOTE_QUERY_SUFFIX @")&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="

//#define QUOTE_QUERY_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.options%20where%20symbol%20in%20("

//#define QUOTE_QUERY_SUFFIX @")&diagnostics=true&env=http%3A%2F%2Fdatatables.org%2Falltables.env"

#define QUOTE_QUERY_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.options%20where%20symbol%20in%20("
#define QUOTE_QUERY_SUFFIX @")&format=json&diagnostics=false&env=http%3A%2F%2Fdatatables.org%2Falltables.env&callback="

+ (NSArray *)fetchQuotesFor:(NSArray *)tickers
{
    // NSMutableDictionary *quotes;  // this should probably be an NSMutableArray
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    // REFACTOR THIS:
    NSString* assetTicket = tickers[0];
    
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
        if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
        NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
        NSArray *quoteEntries = [results valueForKeyPath:@"query.results.optionsChain.option"];
        // quotes = [[NSMutableDictionary alloc] initWithCapacity:[quoteEntries count]];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        for (NSDictionary *quoteEntry in quoteEntries) {
            
            // TODO: init OptionQuote object with quote data and add to quote (NSArray?) dict - DONE
            // TODO: how to cast these things to the correct data type?!?! Things with . are strings, NSUIntegers?
            // NSLog(@"Strike: %@", quoteEntry[@"strikePrice"]);
            [quotes addObject:[[OptionQuote alloc] initWithSymbol:quoteEntry[@"symbol"]
                                                           andAsk:[formatter numberFromString:quoteEntry[@"ask"]]
                                                           andBid:[formatter numberFromString:quoteEntry[@"bid"]]
                                                      atLastPrice:[formatter numberFromString:quoteEntry[@"lastPrice"]]
                                                 withOpenInterest:[formatter numberFromString:quoteEntry[@"openInt"]]
                                                    atStrikePrice:[formatter numberFromString:quoteEntry[@"strikePrice"]]
                                                           ofType:quoteEntry[@"type"]
                                                       withVolume:[formatter numberFromString:quoteEntry[@"vol"]]
                                              andUnderlyingTicker:assetTicket]];
             
            
            //[quotes setValue:[quoteEntry valueForKey:@"lastPrice"] forKey:[quoteEntry valueForKey:@"strikePrice"]];
        }
    }
    return quotes;
}

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


+(NSNumber*)calcUnderlyingVolatility:(NSString *)ticker
{
    //TODO: calc volatility for underlying asset ONCE, and save to underlyingVolatility property
    // TODO: NSDate, NSDateFormatter, NSCalendar(maybe) - how to get start and end dates
    
    //select Adj_Close from yahoo.finance.historicaldata where symbol = "YHOO" and startDate = "2009-09-11" and endDate = "2010-03-10"
    
    // volatility = stddev(quote series) ???
    
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
    
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    NSArray* quoteEntries = [results valueForKeyPath:@"query.results.quote"]; // see what we get
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    for (NSDictionary *quoteEntry in quoteEntries)
    {
        
        [histQuotes addObject:[formatter numberFromString:quoteEntry[@"Adj_Close"]]];
    }
    
    NSLog(@"%@", histQuotes);
    double stdDev = [[self standardDeviationOf:histQuotes] doubleValue];
    double normalizeTerm = sqrt(21);
    
    return [NSNumber numberWithDouble:(stdDev*normalizeTerm)];
    
    
}


@end
