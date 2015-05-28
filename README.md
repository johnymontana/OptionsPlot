OptionsPlot
===========

OptionsPlot downloads options quotes from Yahoo! Finance and uses the <a href="http://finance.bi.no/~bernt/gcc_prog/"> Financial Numercial Recipes C++ library</a> to calculate implied volatilities and other basic options analysis. PFGPlots (Latex) is used to plot the volatility smile and a few other simple plots. OptionsPlot will create a directory (OptionsPlot) in the user's home directory where any generated PDF reports will be saved. See <a href="https://github.com/johnymontana/OptionsPlot/blob/master/ORCL_OptionsPlot.pdf?raw=true">ORCL_OptionsPlot.pdf </a> for an example.


## Volatility Smile

![](/img/smile.png)

## Black-Scholes Model Option Prices vs. Observed Market Prices - using historic volatility

![](/img/atm_iv.png)

## Black-Scholes Model Option Prices vs. Observed Market Prices - using at the money implied volatility

![](/img/historic_vol.png)

Installation:
=============

Dependencies: OptionsPlot requires pdflatex (/usr/texbin/pdflatex) and PFGPlots

Copy OptionsPlot.tex (Resources group) to ~/OptionsPlot/OptionsPlot.tex (see issue #12)

Disclaimer:
============

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or 
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

