//
//  main.m
//  OptionsPlot
//
//  Created by lyonwj on 2/5/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "optionQuoteDownload.h"
#import "OptionQuote.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        
        NSArray* tickers = @[@"AAPL"]; // this should be populated from command line arguments
        
        NSArray *quotes = [optionQuoteDownload fetchQuotesFor:tickers];
        
        NSMutableDictionary *volSmile = [[NSMutableDictionary alloc] init];
        NSFileManager *fm;
        fm = [NSFileManager defaultManager];
        NSString *path;
        NSString* homeDir;
        homeDir = NSHomeDirectory(); // get path to home dir
        
        path = [fm currentDirectoryPath];
        
        
        for (OptionQuote* quote in quotes)
        {
            [quote calcBlackScholesPrice];
            [quote calcImpliedVolatility];
            if ([quote.type isEqual:@"C"])
            {
                [volSmile setObject:quote.impliedVolatility forKey:quote.strikePrice];
            }
            NSLog(@"%@", [quote description]);
            
            
          //  NSLog(@"BS Price: %@", quote.blackScholesPrice);
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
        
      //  NSLog(@"%@",[optionQuoteDownload calcUnderlyingVolatility:@"MSFT"]);
        
        NSLog(@"Home Path: %@", homeDir);
        NSLog(@"Dat file path: %@", datFilePath);
        NSLog(@"Current dir: %@", path);                
        
        [fm changeCurrentDirectoryPath:datFilePath]; // change current dir to ~/OptionsPlot/
        
        // should get user specific paths to executables, this is bad:
        
        [[NSTask launchedTaskWithLaunchPath:@"/usr/texbin/latex" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.tex", datFilePath], nil]] waitUntilExit];
        
        [[NSTask launchedTaskWithLaunchPath:@"/usr/texbin/dvips" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.dvi", datFilePath], nil]] waitUntilExit];
        
        [NSTask launchedTaskWithLaunchPath:@"/usr/local/bin/ps2pdf" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@OptionsPlot.ps", datFilePath], nil]];
    }
    return 0;
}

