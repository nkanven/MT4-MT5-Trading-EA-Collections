//+------------------------------------------------------------------+
//|                                            CloseTransactions.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

CTrade trade;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTransactions(ENUM_SIGNAL_EXIT tType)
  {
   bool  result   =  true;
   int   cnt      =  OrdersTotal();
   int   cts      =  PositionsTotal();
   if(cnt > 0)
     {


      for(int i = cnt-1; i>=0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket))
           {
            if(tType==SIGNAL_EXIT_BUY && (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT || OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP) && OrderGetInteger(ORDER_MAGIC)==InpMagicNumber)
              {
               if(!trade.OrderDelete(ticket))
                  Print("Error (", GetLastError(), ") while deleting all buy orders");
              }
            else
              {
               if(tType==SIGNAL_EXIT_SELL && (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_LIMIT || OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_STOP) && OrderGetInteger(ORDER_MAGIC)==InpMagicNumber)
                 {
                  if(!trade.OrderDelete(ticket))
                     Print("Error (", GetLastError(), ") while deleting all sell orders");
                 }
               else
                 {
                  if(tType==SIGNAL_EXIT_ALL)
                    {
                     if(!trade.OrderDelete(ticket))
                        Print("Error (", GetLastError(), ") while deleting all orders");
                    }
                 }
              }
           }
         else
           {
            Print("Error (", GetLastError(), ") while selecting order's ticket");
           }
        }
     }

   if(cts > 0)
     {
      for(int i = cts-1; i>=0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
           {
            if(tType==SIGNAL_EXIT_BUY && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetInteger(POSITION_MAGIC)==InpMagicNumber)
              {
               if(!trade.PositionClose(ticket))
                  Print("Error (", GetLastError(), ") while deleting all buy positions");
              }
            else
              {
               if(tType==SIGNAL_EXIT_SELL && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetInteger(POSITION_MAGIC)==InpMagicNumber)
                 {
                  if(!trade.PositionClose(ticket))
                     Print("Error (", GetLastError(), ") while deleting all sell positions");
                 }
               else
                 {
                  if(tType==SIGNAL_EXIT_ALL)
                    {
                     if(!trade.PositionClose(ticket))
                        Print("Error (", GetLastError(), ") while deleting all positions");
                    }
                 }
              }

           }
         else
           {
            Print("Error (", GetLastError(), ") while selecting position by ticket");
           }
        }
     }
  }
//+------------------------------------------------------------------+
