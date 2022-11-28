//+------------------------------------------------------------------+
//|                                               NewCandleAlert.mq5 |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin.com/in/nkondog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin.com/in/nkondog"
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
   newBar();
  }
//+------------------------------------------------------------------+

bool newBar()
  {
   static datetime prevTime    = 0;
   datetime        currentTime = iTime(Symbol(), PERIOD_CURRENT, 0);
   if(currentTime != prevTime)
     {
      prevTime = currentTime;

      Alert("New candle");
      
      return(true);
     }
   return(false);
  }