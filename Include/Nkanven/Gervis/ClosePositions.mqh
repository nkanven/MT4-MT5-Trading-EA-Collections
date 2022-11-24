//+------------------------------------------------------------------+
//|                                               ClosePositions.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

CTrade trade;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderClose()
  {
   bool  result   =  true;
   int   cnt      =  OrdersTotal();
   if(cnt == 1)
     {


      for(int i = cnt-1; i>=0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket))
           {

            result   &= trade.OrderDelete(ticket);
           }
         else
           {
            result   =  false;
           }
        }
     }
   return(result);
  }
//+------------------------------------------------------------------+
