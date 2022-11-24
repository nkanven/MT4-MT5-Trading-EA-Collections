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
   bool day_trading = false, night_trading = false;
   gIsOperatingHours=false;

//If we are not using operating hours then IsOperatingHours is true and I skip the other checks
   if(!InpUseTradingHours || InpTradingPeriods == ALL_DAY_TRADING)
     {
      gIsOperatingHours=true;
      Print("Round clock trading");
      return;
     }
     
   if(InpTradingPeriods == DAY_TRADING)
     {
     Print("dt.hour ", dt.hour," >= InpDayTradingHourStart ", InpDayTradingHourStart ," ", dt.hour >= InpDayTradingHourStart);
     Print("dt.hour ", dt.hour," <= InpDayTradingHourEnd ", InpDayTradingHourEnd ," ", dt.hour <= InpDayTradingHourEnd);
     
      //Check day trading hours
      if(dt.hour >= InpDayTradingHourStart && dt.hour <= InpDayTradingHourEnd)
        {
         day_trading = true;
         gIsOperatingHours=true;
         Print("Day period trading");
         return;
        }

     }
Print("InpTradingPeriods == NIGHT_TRADING ", InpTradingPeriods == NIGHT_TRADING);
   if(InpTradingPeriods == NIGHT_TRADING)
     {
      //Check night trading hours
      if(dt.hour >= InpNightTradingHourStart && dt.hour <= InpNightTradingHourEnd)
        {
         night_trading = true;
         gIsOperatingHours=true;
         Print("Night period trading");
         return;
        }
     }

   if(InpTradingPeriods == DAY_NIGHT_TRADING)
     {
      //Check night trading hours
      if(day_trading || night_trading)
        {
         gIsOperatingHours=true;
         Print("Day and night periods trading");
         return;
        }
     }
  }
//+------------------------------------------------------------------+
