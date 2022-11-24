//+------------------------------------------------------------------+
//|                                                    Functions.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


//Check and return if the spread is not too high
void CheckSpread()
  {
//Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   long SpreadCurr=(int)Spread;
   Print("Spread ", Spread);
   if(SpreadCurr<=InpMaxSpread)
     {
      IsSpreadOK=true;
     }
   else
     {
      IsSpreadOK=false;
     }
  }
  
double GetSignalBoundries()
{
   //Get midnight high and low
   iHigh()
}