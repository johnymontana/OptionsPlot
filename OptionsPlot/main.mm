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
        
        
        NSArray* tickers = @[@"GOOG"]; // this should be populated from command line arguments
        
        int funcCallCount = 0;                  // used for profiling method calls
        double timeForCalcBSPrice = 0.;
        double timeForCalcIV = 0.;
        double timeForCalcBSPriceUsingIV = 0.;
        
        NSDate* methodStart = [NSDate date];
        NSArray *quotes = [OptionQuoteDownload fetchQuotesFor:tickers];     // download options quotes
        NSDate* methodFinish = [NSDate date];
        double timeForOptionQuoteDownload = [methodFinish timeIntervalSinceDate:methodStart];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *path = [fm currentDirectoryPath];
        NSString* homeDir = NSHomeDirectory(); // get path to home dir
        

        
        NSMutableDictionary* historicVol = [[NSMutableDictionary alloc] init];  // coordinates for historical volatility plot
        NSMutableDictionary *volSmile = [[NSMutableDictionary alloc] init];     // coordinates for volatility smile plot
        
        NSMutableDictionary *impliedVolCoords = [[NSMutableDictionary alloc] init]; // coordinates for implied volatility plot
        
        NSNumber* IV = [[NSNumber alloc] init];
        
        
        
        for (OptionQuote* quote in quotes)
        {
            NSDate* methodStart = [NSDate date];
            [quote calcBlackScholesPrice];                      // update quotes with BS price
            NSDate* methodFinish = [NSDate date];
            timeForCalcBSPrice += [methodFinish timeIntervalSinceDate:methodStart];
            // NSLog(@"Time to execute calcBlackScholes: %f", exeTime);
            
            methodStart = [NSDate date];
            [quote calcImpliedVolatility];                      // update quotes with IVs
            methodFinish = [NSDate date];
            timeForCalcIV += [methodFinish timeIntervalSinceDate:methodStart];
            IV = [OptionQuote getImpliedVolatilityInTheMoney:quotes];
            methodStart = [NSDate date];
            [quote calcBlackScholesPriceUsingVolatility:IV];    // update quotes with BS price using at-the-money IV
            methodFinish = [NSDate date];
            timeForCalcBSPriceUsingIV += [methodFinish timeIntervalSinceDate:methodStart];
            
            
            if ([quote.type isEqual:@"C"])      // set coords for volatility smile (calls only)
            {
                [volSmile setObject:quote.impliedVolatility forKey:quote.strikePrice];
            }
            
            // set coords for mrkt vs. bs price (historic volatility & IV)
            [historicVol setObject:quote.lastPrice forKey:quote.blackScholesPrice]; // coord= (lastPrice, blackScholesPrice)
            [impliedVolCoords setObject:quote.lastPrice forKey:quote.blackScholesPrice_IV]; // coord = (lastPrice, blackScholesPrice_IV)
            
            NSLog(@"%@", [quote description]);
            
            
          //  NSLog(@"BS Price: %@", quote.blackScholesPrice);
            funcCallCount++;
        }
        
        
        
        NSLog(@"%@", volSmile);
        
        NSString* line; // will hold a single (strike, volatility) coordinate
        NSMutableString* datFileString = [[NSMutableString alloc] init]; // to be written to dat file
        
        
        // BEGIN gen tex report
        methodStart = [NSDate date];
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
        
        // Define latex macros to use in template.tex
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
        
              
        NSLog(@"Home Path: %@", homeDir);
        NSLog(@"Dat file path: %@", datFilePath);
        NSLog(@"Current dir: %@", path);                
        
        [fm changeCurrentDirectoryPath:datFilePath]; // change current dir to ~/OptionsPlot/
        
        // should get user specific paths to executables, this is bad:
        
        [[NSTask launchedTaskWithLaunchPath:@"/usr/texbin/pdflatex" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.tex", datFilePath], nil]] waitUntilExit];
        
        methodFinish = [NSDate date];
        double timeForGenTexPDF = [methodFinish timeIntervalSinceDate:methodStart];
        // don't need dvips, ps2pdf if using pdflatex
        // [[NSTask launchedTaskWithLaunchPath:@"/usr/texbin/dvips" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.dvi", datFilePath], nil]] waitUntilExit];
        
        //[NSTask launchedTaskWithLaunchPath:@"/usr/local/bin/ps2pdf" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.ps", datFilePath], nil]];
        
        NSLog(@"Avg time for CalcBSPrice: %f millisecs", (timeForCalcBSPrice/funcCallCount)*1000.);
        NSLog(@"Avg time for CalcBSPriceUsingIV: %f millisecs", (timeForCalcBSPriceUsingIV/funcCallCount)*1000.);
        NSLog(@"Avg time for CalcIV: %f millisecs", (timeForCalcIV/funcCallCount)*1000.);
        NSLog(@"Time for OptionQuoteDownload: %f secs", timeForOptionQuoteDownload);
        NSLog(@"Time to generate tex/PDF: %f secs", timeForGenTexPDF);
    
    }
    return 0;
}

