//+------------------------------------------------------------------+
//|                                       DL_CheckOperationHours.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Check and return if it is operation hours or not
void CheckOperationHours()
  {
//If we are not using operating hours then IsOperatingHours is true and I skip the other checks
   if(!UseTradingHours)
     {
      IsOperatingHours=true;
      return;
     }
//Check if the current hour is between the allowed hours of operations, if so IsOperatingHours is set true
   Print("1 this is ", (TradingHourStart==TradingHourEnd && dt.hour==TradingHourStart && In_Trade));

   if(TradingHourStart==TradingHourEnd && dt.hour==TradingHourStart && In_Trade)
      IsOperatingHours=true;

   if(TradingHourStart<TradingHourEnd && In_Trade)
     {
      if(TradingHourStart == dt.hour && dt.min >= TradingStartMin)
        {
         IsOperatingHours=true;
        }
      if(dt.hour > TradingHourStart)
        {
         IsOperatingHours=true;
        }
     }
   
   if(TradingHourStart>TradingHourEnd && ((dt.hour>=TradingHourStart && dt.hour<=23) || (dt.hour<=TradingHourEnd && dt.hour>=0)) && In_Trade)
     {
      IsOperatingHours=true;
     }
     
     if(IsOperatingHours == false)
       {
        rangeUpdated = false;
       }
  }
//+------------------------------------------------------------------+
