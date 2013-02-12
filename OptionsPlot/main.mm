//
//  main.m
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OptionQuoteDownload.h"
#import "OptionQuote.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        
        NSArray* tickers = @[@"ORCL"]; // this should be populated from command line arguments
        
        NSDate* methodStart = [NSDate date];
        NSArray *quotes = [OptionQuoteDownload fetchQuotesFor:tickers];
        NSDate* methodFinish = [NSDate date];
        
        double timeForOptionQuoteDownload = [methodFinish timeIntervalSinceDate:methodStart];
        
        NSFileManager *fm;
        fm = [NSFileManager defaultManager];
        NSString *path;
        NSString* homeDir;
        homeDir = NSHomeDirectory(); // get path to home dir
        
        path = [fm currentDirectoryPath];
        
        NSMutableDictionary* historicVol = [[NSMutableDictionary alloc] init];  // coordinates for historical volatility plot
        NSMutableDictionary *volSmile = [[NSMutableDictionary alloc] init];     // coordinates for volatility smile plot
        
        NSMutableDictionary *impliedVolCoords = [[NSMutableDictionary alloc] init]; // coordinates for implied volatility plot
        
        NSNumber* IV = [[NSNumber alloc] init];
        int funcCallCount = 0;
        double timeForCalcBSPrice = 0.;
        double timeForCalcIV = 0.;
        double timeForCalcBSPriceUsingIV = 0.;
        
        for (OptionQuote* quote in quotes)
        {
            NSDate* methodStart = [NSDate date];
            [quote calcBlackScholesPrice];                      // TODO: profile this
            NSDate* methodFinish = [NSDate date];
            timeForCalcBSPrice += [methodFinish timeIntervalSinceDate:methodStart];
            // NSLog(@"Time to execute calcBlackScholes: %f", exeTime);
            
            methodStart = [NSDate date];
            [quote calcImpliedVolatility];                      // TODO: profile this
            methodFinish = [NSDate date];
            timeForCalcIV += [methodFinish timeIntervalSinceDate:methodStart];
            
            methodStart = [NSDate date];
            [quote calcBlackScholesPriceUsingVolatility:IV];    // TODO: profile this
            methodFinish = [NSDate date];
            timeForCalcBSPriceUsingIV += [methodFinish timeIntervalSinceDate:methodStart];
            
            IV = [OptionQuote getImpliedVolatilityInTheMoney:quotes];
            if ([quote.type isEqual:@"C"])
            {
                [volSmile setObject:quote.impliedVolatility forKey:quote.strikePrice];
            }
            
            [historicVol setObject:quote.lastPrice forKey:quote.blackScholesPrice]; // coord= (lastPrice, blackScholesPrice)
            [impliedVolCoords setObject:quote.lastPrice forKey:quote.blackScholesPrice_IV]; // coord = (lastPrice, blackScholesPrice_IV)
            
            NSLog(@"%@", [quote description]);
            
            
          //  NSLog(@"BS Price: %@", quote.blackScholesPrice);
            funcCallCount++;
        }
        
        
        
        NSLog(@"%@", volSmile);
        
        NSString* line; // will hold a single (strike, volatility) coordinate
        NSMutableString* datFileString = [[NSMutableString alloc] init];
        for (id key in volSmile)
        {
            line = [NSString stringWithFormat:@"%@ %@\n", key, volSmile[key]]; // get (strike, volatility) coordinate
            
            [datFileString appendString:line]; // append to list of coordinates
            
        }
        
        NSString* datFilePath = [NSString stringWithFormat:@"%@/OptionsPlot/", homeDir]; // create path for ~/OptionsPlot
        
        [fm createDirectoryAtPath:datFilePath withIntermediateDirectories:NO attributes:nil error:nil]; // create dir ~/OptionsPlot/ if does not exist
        
        [datFileString writeToFile:[NSString stringWithFormat:@"%@/coords.dat",datFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil]; // write coordinates to coords.dat file
        
        datFileString = [[NSMutableString alloc] init];
        for (id key in historicVol)
        {
            line = [NSString stringWithFormat:@"%@ %@\n", key, historicVol[key]];
            [datFileString appendString:line];
            
        }
        
        [datFileString writeToFile:[NSString stringWithFormat:@"%@/hist_coords.dat",datFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        datFileString = [[NSMutableString alloc] init];
        for (id key in impliedVolCoords)
        {
            line = [NSString stringWithFormat:@"%@ %@\n", key, impliedVolCoords[key]];
            [datFileString appendString:line];
        }
        
        [datFileString writeToFile:[NSString stringWithFormat:@"%@/iv_coords.dat", datFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSMutableString* texVars= [[NSMutableString alloc] init];
        
        line = [NSString stringWithFormat:@"\\newcommand{\\ticker}{%@ }", tickers[0]];
        [texVars appendString:line];
        line = [NSString stringWithFormat:@"\\newcommand{\\expiration}{ %@ }", [[quotes[0] expiration] description]];
        [texVars appendString:line];
        line = @"\\newcommand{\\callorput}{ Call}";
        [texVars appendString:line];
        line = [NSString stringWithFormat:@"\\newcommand{\\underlyingquote}{%@}", [[quotes[0] spotPrice] description]];
        [texVars appendString:line];
        line = [NSString stringWithFormat:@"\\newcommand{\\histvolatility}{%@}", [[quotes[0] underlyingVolatility] description]];
        [texVars appendString:line];
        line = [NSString stringWithFormat:@"\\newcommand{\\impliedvolatility}{%@}", [IV description]];
        [texVars appendString:line];
        [texVars writeToFile:[NSString stringWithFormat:@"%@/variables.tex", datFilePath] atomically:NO encoding:NSUTF8StringEncoding error:nil];
        
      //  NSLog(@"%@",[optionQuoteDownload calcUnderlyingVolatility:@"MSFT"]);
        
        NSLog(@"Home Path: %@", homeDir);
        NSLog(@"Dat file path: %@", datFilePath);
        NSLog(@"Current dir: %@", path);                
        
        [fm changeCurrentDirectoryPath:datFilePath]; // change current dir to ~/OptionsPlot/
        
        // should get user specific paths to executables, this is bad:
        
        [[NSTask launchedTaskWithLaunchPath:@"/usr/texbin/pdflatex" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.tex", datFilePath], nil]] waitUntilExit];
        
       // [[NSTask launchedTaskWithLaunchPath:@"/usr/texbin/dvips" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.dvi", datFilePath], nil]] waitUntilExit];
        
        //[NSTask launchedTaskWithLaunchPath:@"/usr/local/bin/ps2pdf" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.ps", datFilePath], nil]];
        NSLog(@"Avg CPU time for CalcBSPrice: %f millisecs", (timeForCalcBSPrice/funcCallCount)*1000.);
        NSLog(@"Avg CPU time for CalcBSPriceUsingIV: %f millisecs", (timeForCalcBSPriceUsingIV/funcCallCount)*1000.);
        NSLog(@"Avg CPU time for CalcIV: %f millisecs", (timeForCalcIV/funcCallCount)*1000.);
        NSLog(@"CPU time for OptionQuoteDownload: %f secs", timeForOptionQuoteDownload);
    
    }
    return 0;
}

