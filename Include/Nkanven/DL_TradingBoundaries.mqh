//+------------------------------------------------------------------+
//|                                         DL_TradingBoundaries.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

double newHigh, newLow;
bool rangeUpdated = false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawRange()
  {
   string candles_times;
   int    time_to_string;
   ushort a;
   string d_time = TimeToString(iTime(Symb,PERIOD_M5,0), TIME_MINUTES);
   string open_hour[];
   string obj_name = "Upper boundary", obj_name_l = "Lower boundary";

   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,_Period,0,MaxCandleIteration,High);

   ArraySetAsSeries(Low,true);
   CopyLow(_Symbol,_Period,0,MaxCandleIteration,Low);

//--- Get the separator code
   a = StringGetCharacter(":",0);

   int k = StringSplit(d_time, a, open_hour);

   if(k>0)
     {
      server_time = "Server time on last 5 Min candle => Hour = " +open_hour[0]+ ", Minute = " +open_hour[1];
     }

// Get trading range
   for(int j = 0; j <= MaxCandleIteration; j++)
     {
      string result[];
      candles_times = TimeToString(iTime(Symb,_Period,j), TIME_MINUTES);
      time_to_string = StringSplit(candles_times, a, result);
      //Print("Is trading boundary "+(result[0] == TradingBoundaryHour && result[1] == TradingBoundaryMin));
      if(result[0] == TradingBoundaryHour && result[1] == TradingBoundaryMin)
        {
         if(!rangeUpdated)
           {
            upper_boundary = iHigh(Symb, _Period, j) + rangemargin;
            lower_boundary = iLow(Symb, _Period, j)- rangemargin;
           }

         UpdateRange();
         //Print("Iteration no "+iTime(Symb,PERIOD_M5,j));
         ObjectCreate(current_chart_id, obj_name, OBJ_HLINE, 0, iTime(Symb,_Period,j), upper_boundary);

         //--- set color to Red
         ObjectSetInteger(current_chart_id, obj_name, OBJPROP_COLOR, clrRed);
         //--- set object width
         ObjectSetInteger(current_chart_id, obj_name, OBJPROP_WIDTH, 2);
         //--- Move the line
         ObjectMove(current_chart_id, obj_name, 0, iTime(Symb,_Period,j), upper_boundary);

         ObjectCreate(current_chart_id, obj_name_l, OBJ_HLINE, 0, iTime(Symb,_Period,j), lower_boundary);

         //--- set color to Red
         ObjectSetInteger(current_chart_id, obj_name_l, OBJPROP_COLOR, clrRed);
         //--- set object width
         ObjectSetInteger(current_chart_id, obj_name_l, OBJPROP_WIDTH, 2);
         //--- Move the line
         ObjectMove(current_chart_id, obj_name_l, 0, iTime(Symb,_Period,j), lower_boundary);

         if(!rangedetection)
           {
            upper_boundary = upperboundary;
            lower_boundary = lowerboundary;
           }

         //Print("upper_boundary ", upper_boundary, " lower_boundary ", lower_boundary);
         //Print("Real high ", iHigh(Symb, PERIOD_M5, j), " Real low ", iLow(Symb, PERIOD_M5, j), " as of ", TimeToString(iTime(Symb,PERIOD_M5, j)));
         In_Trade = true;
         rangeScope = fabs(upper_boundary-lower_boundary);
         break;
        }
      ObjectDelete(current_chart_id, obj_name_l);
      ObjectDelete(current_chart_id, obj_name);
      In_Trade = false;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateRange()
  {
   newHigh = iHigh(Symb, PERIOD_CURRENT, 0);
   newLow = iLow(Symb, PERIOD_CURRENT, 0);
   Print("Updating range high from ", upper_boundary, "to ", newHigh, " and low from ", lower_boundary, " to ", newLow);
   if(newHigh > upper_boundary && TotalOpenBuy > 0)
     {
      upper_boundary = newHigh;
      rangeUpdated = true;
     }
   if(lower_boundary > newLow && TotalOpenSell > 0)
     {
      lower_boundary = newLow;
      rangeUpdated = true;
     }
  }
//+------------------------------------------------------------------+
