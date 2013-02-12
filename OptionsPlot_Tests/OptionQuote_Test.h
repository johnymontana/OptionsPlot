//
//  OptionQuote_Test.h
//  OptionsPlot
//
//  Created by lyonwj on 2/12/13.
//  Copyright (c) 2013 William Lyon. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class OptionQuote;

@interface OptionQuote_Test : SenTestCase
{
    OptionQuote* quote;
    OptionQuote* quote1;
    OptionQuote* quote2;
    OptionQuote* quote3;
    
    NSArray* arrayOfQuotes;
}

@end
