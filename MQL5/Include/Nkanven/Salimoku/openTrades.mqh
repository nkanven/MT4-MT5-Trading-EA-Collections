//+------------------------------------------------------------------+
//|                                                   openTrades.mqh |
//|                       Copyright 2023, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin.com/in/nkondog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin.com/in/nkondog"

//Execute entry if there is an entry signal
void ExecuteEntry()
  {
   //If there is no entry signal no point to continue, exit the function
   if(SignalEntry == SIGNAL_ENTRY_NEUTRAL)
      return;

   int Operation;
   double OpenPrice = 0;
   double StopLossPrice = 0;
   double TakeProfitPrice = 0;
   double uMinStopLoss = 0;
   double uStopLoss = 0;
   double uTakeProfit = 0;
   double _sldiff = 0;

   uMinStopLoss = StopLoss * 10;
   uTakeProfit = TakeProfit * 10;

   Print("Entry signal execute ", SignalEntry);

   //If there is a Buy entry signal
   if(SignalEntry == SIGNAL_ENTRY_BUY && TotalOpenBuy == 0)
     {
      Print("In buy execution");
      Operation = ORDER_TYPE_BUY; //Set the operation to BUY
      OpenPrice = last_tick.ask;    //Set the open price to Ask price
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode == SL_FIXED && uStopLoss > 0)
        {
         StopLossPrice = OpenPrice - ((uStopLoss + uMinStopLoss) * Point());
        }

      //If the Stop Loss is automatic
      if(StopLossMode == SL_AUTO)
        {
        _sldiff = (OpenPrice - Kijunsen);
        Print("Long diff ", _sldiff, " ", (uMinStopLoss * Point()));
        StopLossPrice = Kijunsen;
        
        if(_sldiff < (uMinStopLoss * Point()))
          {
           StopLossPrice = OpenPrice - (uMinStopLoss * Point());
          }
        }

      //If the Take Profix price is fixed and defined
      if(TakeProfitMode == TP_FIXED && uTakeProfit > 0)
        {
         TakeProfitPrice = OpenPrice + uTakeProfit * Point();
        }
      //If the Take Profit is automatic
      if(TakeProfitMode == TP_AUTO)
        {
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice = OpenPrice + ((OpenPrice - StopLossPrice) * TakeProfitPercent);
        }
      Print("Stop loss ", StopLossPrice, " Digits ", Digits());

      if(AtrStopLoss)
         StopLossPrice = OpenPrice - (Atr * atr_sl_factor);

      OpenPrice = NormalizeDouble(OpenPrice, Digits());
      StopLossPrice = NormalizeDouble(StopLossPrice, Digits());
      TakeProfitPrice = NormalizeDouble(TakeProfitPrice, Digits());

      //Submit the order
      Print("Sending buy order Stop loss ", StopLossPrice);
      SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice);
     }

     if(SignalEntry == SIGNAL_ENTRY_SELL && TotalOpenSell ==  0)
     { 
      Print("In sell execution");
      Operation = ORDER_TYPE_SELL; //Set the operation to SELL
      OpenPrice = last_tick.bid;    //Set the open price to Ask price
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode == SL_FIXED && StopLoss > 0)
        {
         StopLossPrice = OpenPrice + StopLoss *Point();
        }
      //If the Stop Loss is automatic
      if(StopLossMode == SL_AUTO)
        {
           _sldiff = (Kijunsen - OpenPrice);
           Print("Long diff ", _sldiff, " ", (uMinStopLoss * Point()));
           StopLossPrice = Kijunsen;
           
           if(_sldiff < (uMinStopLoss * Point()))
             {
              StopLossPrice = OpenPrice + (uMinStopLoss * Point());
             }
        }
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode == TP_FIXED)
        {
         if(TakeProfit > 0)
           {
            TakeProfitPrice = 0;
           }
         else
           {
            TakeProfitPrice = OpenPrice - (uTakeProfit * Point());
           }
        }

      //If the Take Profit is automatic
      if(TakeProfitMode == TP_AUTO)
        {
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice = OpenPrice - ((StopLossPrice - OpenPrice) * TakeProfitPercent);
         //Alert("Take profit ", (rangeScope*takeprofitpercent));
        }

      if(AtrStopLoss)
         StopLossPrice = OpenPrice + (Atr*atr_sl_factor);

      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice);
     }
  }


//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int Command, string Instrument, double OpenPrice, double SLPrice, double TPPrice, datetime Expiration=0)
  {
   MqlTradeRequest request= {};
   MqlTradeResult  result= {};
//Retry a number of times in case the submission fails
   for(int i=1; i<=OrderOpRetry; i++)
     {
      //Set the color for the open arrow for the order
      /*color OpenColor=clrBlueViolet;
      if(Command==OP_BUY)
        {
         OpenColor=clrChartreuse;
        }
      if(Command==OP_SELL)
        {
         OpenColor=clrDarkTurquoise;
        }*/
      //Calculate the position size, if the lot size is zero then exit the function
      double SLPoints=0;
      //If the Stop Loss price is set then find the points of distance between open price and stop loss price, and round it
      if(SLPrice>0)
         SLPoints=MathCeil(MathAbs(OpenPrice-SLPrice)/Point());
      //Call the function to calculate the position size
      Print("Open price - SL Price", OpenPrice, SLPrice);
      //CheckHistory();

      LotSizeCalculate(SLPoints);
      //If the position size is zero then exit and don't submit any orderInit

      Print("Stop loss en point ", SLPoints);
      if(LotSize==0)
         return;

      request.action       =TRADE_ACTION_DEAL;                     // type de l'opération de trading
      request.symbol       =Instrument;                              // symbole
      request.volume       =LotSize;                                   // volume de 0.1 lot
      request.type         =Command;                        // type de l'ordre
      request.price        =SYMBOL_TRADE_EXECUTION_MARKET; // prix d'ouverture
      request.sl           =NormalizeDouble(SLPrice,Digits());
      request.tp           =NormalizeDouble(TPPrice,Digits());
      request.type_filling =ORDER_FILLING_FOK;
      request.deviation    =Slippage;
      request.expiration   =Expiration;                             // déviation du prix autorisée
      //Submit the order

      if(!OrderSend(request,result))
         PrintFormat("OrderSend erreur %d",GetLastError());     // en cas d'erreur d'envoi de la demande, affiche le code d'erreur
      //--- informations de l'opération
      PrintFormat("retcode=%u  transaction=%I64u  ordre=%I64u",result.retcode,result.deal,result.order);

      if(result.retcode == TRADE_RETCODE_DONE && result.deal != 0)
        {
         FollowProfit = false;
         PositionProfit = 0;
         break;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
