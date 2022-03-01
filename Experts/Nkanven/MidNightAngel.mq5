//+------------------------------------------------------------------+
//|                                                MidNightAngel.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //---
   datetime ht = TimeCurrent();
   TimeToStruct(ht, dt);

   printf("On tick--------------------------- on "+dt.hour);
   SymbolInfoTick(_Symbol,last_tick);
 
      //Store equity
      //Verify trading time
      //Check losing position
         //if yes
            //Check tree last closed positions
               //if all 3 loss -> x8
            //if equity < storeEquity -> x4    
         //else place x1 buy trade
         
         //if equity > storeEquity -> update storeEquity

   if(condition)
     {
      
     }
 
   //Check opened trade
   
   
  }
//+------------------------------------------------------------------+

//Check and return if the spread is not too high
void CheckSpread()
  {
//Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   long SpreadCurr=Spread;
   Print("Spread ", SpreadCurr);
   if(SpreadCurr<=MaxSpread)
     {
      IsSpreadOK=true;
     }
   else
     {
      IsSpreadOK=false;
     }
  }
//+------------------------------------------------------------------+
