//+------------------------------------------------------------------+
//|                                            HighestPriceLevel.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawLine()
  {
   string obj_name = "Recent high";

   if(highestPrice != gLastHighestPrice)
     {
      ObjectDelete(current_chart_id, obj_name);
     }
   ObjectCreate(current_chart_id, obj_name, OBJ_HLINE, 0, iTime(gSymbol,_Period,0), gLastHighestPrice);

//--- set color to Red
   ObjectSetInteger(current_chart_id, obj_name, OBJPROP_COLOR, clrRed);
//--- set object width
   ObjectSetInteger(current_chart_id, obj_name, OBJPROP_WIDTH, 1);
//--- Move the line
   ObjectMove(current_chart_id, obj_name, 0, iTime(gSymbol,_Period,0), gLastHighestPrice);

   highestPrice = gLastHighestPrice;
   
   Print("Drawing line");
  }
//+------------------------------------------------------------------+
