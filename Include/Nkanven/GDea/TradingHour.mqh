//+------------------------------------------------------------------+
//|                                                  TradingHour.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Check and return if it is operation hours or not
void CheckOperationHours()
  {
//If we are not using operating hours then IsOperatingHours is true and I skip the other checks
   if(!InpUseTradingHours)
     {
      gIsOperatingHours=true;
      return;
     }
//Check if the current hour is between the allowed hours of operations, if so IsOperatingHours is set true
   Print("1 this is ", (InpTradingHourStart==InpTradingHourEnd && dt.hour==InpTradingHourStart));

   if(InpTradingHourStart==InpTradingHourEnd && dt.hour==InpTradingHourStart)
     {
      gIsOperatingHours=true;
      return;
     }

   if(InpTradingHourStart<InpTradingHourEnd)
     {
      if(InpTradingHourStart == dt.hour && dt.min >= InpTradingStartMin)
        {
         gIsOperatingHours=true;
         return;
        }
      if(dt.hour > InpTradingHourStart)
        {
         gIsOperatingHours=true;
        }
     }

   if(InpTradingHourStart>InpTradingHourEnd && ((dt.hour>=InpTradingHourStart && dt.hour<=23) || (dt.hour<=InpTradingHourEnd && dt.hour>=0)))
     {
      gIsOperatingHours=true;
     }
  }
//+------------------------------------------------------------------+
