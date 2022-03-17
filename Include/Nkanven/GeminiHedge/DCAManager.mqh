//+------------------------------------------------------------------+
//|                                                   DCAManager.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DcaManager()
  {
//Compute pending orders levels
   ENUM_DCA_STATUS dcaStatus = DcaWatcher();

   switch(dcaStatus)
     {
      case  NO_DEALS :
         signal = NO_SIGNAL;
         break;
      case  NO_BUY_POSITIONS :
         signal = BUY_SIGNAL;
         break;
      case  BUY_PENDING_ORDERS :
         signal = PENDING_ORDERS;
         break;
      case  NO_UPPER_BUY_ORDERS :
         signal = BUY_STOP_SIGNAL;
         break;
      case  NO_LOWER_BUY_ORDERS :
         signal = BUY_LIMIT_SIGNAL;
         break;
      case  BUY_POSITION_EXISTS :
         signal = NO_SIGNAL;
         break;
      default:
         signal = NO_SIGNAL;
         break;
     }


  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DCA_STATUS DcaWatcher()
  {
   if(gTotalBuyPositions > 0)
     {
      //Get last opened position id
      int lastTicketId = gTotalBuyPositions;

      bool hasOrderAbove = false, hasOrderBelow = false;

      if(PositionGetTicket(lastTicketId) == 0)
        {
         int Error=GetLastError();
         Print("ERROR - Unable to select the order - ",Error," - ",Error);
         return NO_DEALS;
        }

      if(PositionGetSymbol(lastTicketId)==gSymbol && PositionGetInteger(POSITION_MAGIC)==InpMagicNumber)
        {
         //Compute above and below orders price
         
         Print("Last ticket id ", lastTicketId, " last ticket price ", PositionGetDouble(POSITION_PRICE_OPEN));
         gUpOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN) + (InpBuyCallBack * point);
         gDownOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN) - (InpBuyCallBack * point);

         //Check orders around the last opened position
         for(int i=0; i<gTotalOrders; i++)
           {
            //If there is a problem reading the order print the error, exit the function and return false
            if(OrderGetTicket(i) == 0)
              {
               int Error=GetLastError();
               Print("ERROR - Unable to select the order - ",Error," - ",Error);
               return NO_DEALS;
              }

            //Check existence of above and below orders to last opened position
            if(OrderGetString(ORDER_SYMBOL)==gSymbol && OrderGetInteger(ORDER_MAGIC)==InpMagicNumber)
              {
               if(gUpOpenPrice == OrderGetDouble(ORDER_PRICE_OPEN))
                 {
                  hasOrderAbove = true;
                 }
               if(gDownOpenPrice == OrderGetDouble(ORDER_PRICE_OPEN))
                 {
                  hasOrderBelow = true;
                 }
              }
           }

         //Do nothing if both orders exist
         if(hasOrderAbove && hasOrderBelow)
           {
            return NO_DEALS;
           }

         //Report non existence of one or both orders
         if(!hasOrderAbove && hasOrderBelow)
           {
            return NO_UPPER_BUY_ORDERS;
           }
         if(hasOrderAbove && !hasOrderBelow)
           {
            return NO_LOWER_BUY_ORDERS;
           }
         if(!hasOrderAbove && !hasOrderBelow)
           {
            return BUY_PENDING_ORDERS;
           }

         return BUY_POSITION_EXISTS;
        }
     }
   else
     {
      return NO_BUY_POSITIONS;
     }
   return NO_DEALS;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
