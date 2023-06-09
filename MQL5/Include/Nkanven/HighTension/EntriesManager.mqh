//+------------------------------------------------------------------+
//|                                            EntriesManagement.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExecuteEntry()
  {

   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;

//Place market order
   if(tradeSignal() == BUY_SIGNAL && gTotalBuyPositions == 0)
     {

      OpenPrice=last_tick.ask;    //Set the open price to Ask price

      //If the Stop Loss is fixed and the default stop loss is set
      if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0 && !InpDisableStopLoss)
        {
         StopLossPrice=OpenPrice-(InpDefaultStopLoss*Point());
        }

      //If the Stop Loss is set to automatic
      if(InpStopLossMode==SL_AUTO && !InpDisableStopLoss)
        {
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=getAutoStopLoss(BUY_SIGNAL);
        }

      //If the Take Profix price is fixed and defined
      if(InpTakeProfitMode==TP_FIXED && InpDefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice+InpDefaultTakeProfit*Point();
        }
      //If the Take Profit is automatic
      if(InpTakeProfitMode==TP_AUTO)
        {
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice = OpenPrice + ((OpenPrice - getAutoStopLoss(BUY_SIGNAL))*InpTakeProfitPercent);
        }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      //SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_BUY,gSymbol,OpenPrice,StopLossPrice,TakeProfitPrice);

     }

   if(tradeSignal() == SELL_SIGNAL && gTotalSellPositions == 0)
     {

      OpenPrice=last_tick.bid;    //Set the open price to Ask price

      //InpAtrMultiplier

      //If the Stop Loss is fixed and the default stop loss is set
      if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0 && !InpDisableStopLoss)
        {
         StopLossPrice=OpenPrice+(InpDefaultStopLoss*Point());
        }

      //If the Stop Loss is set to automatic
      if(InpStopLossMode==SL_AUTO && !InpDisableStopLoss)
        {
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=getAutoStopLoss(SELL_SIGNAL);
        }

      //If the Take Profix price is fixed and defined
      if(InpTakeProfitMode==TP_FIXED && InpDefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice-InpDefaultTakeProfit*Point();
        }
      //If the Take Profit is automatic
      if(InpTakeProfitMode==TP_AUTO)
        {
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=OpenPrice-((getAutoStopLoss(SELL_SIGNAL) - OpenPrice) * InpTakeProfitPercent);
        }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      //SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_SELL,gSymbol,OpenPrice,StopLossPrice,TakeProfitPrice);
     }
  }

//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int action, int Command, string Instrument, double OpenPrice, double SLPrice, double TPPrice, datetime Expiration=0)
  {
   MqlTradeRequest request= {};
   MqlTradeResult  result= {};

//Retry a number of times in case the submission fails
   for(int i=1; i<=gOrderOpRetry; i++)
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
      Print("Stop loss ", SLPrice, " Open price ", OpenPrice);
      //If the Stop Loss price is set then find the points of distance between open price and stop loss price, and round it
      if(SLPrice>0)
         SLPoints=MathCeil(MathAbs(OpenPrice-SLPrice)/_Point);
      //Call the function to calculate the position size
      //CheckHistory();
      Print("Stop loss en point ", SLPoints, " Point ", _Point);
      LotSizeCalculate(SLPoints);
      //If the position size is zero then exit and don't submit any orderInit

      Print("Stop loss en point ", SLPoints);
      Print("gLotSize ", gLotSize);
      if(gLotSize==0)
         return;

      request.action       =action;                     // type de l'opération de trading
      request.symbol       =Instrument;                              // symbole
      request.volume       =gLotSize;                                   // volume de 0.1 lot
      request.type         =Command;                        // type de l'ordre
      request.price        =OpenPrice; // prix d'ouverture
      request.sl           =NormalizeDouble(SLPrice,Digits());
      request.tp           =NormalizeDouble(TPPrice,Digits());
      request.deviation    =InpSlippage;
      request.expiration   =Expiration;                             // déviation du prix autorisée
      request.magic        =InpMagicNumber;

      if(!OrderSend(request,result))
        {
         PrintFormat("OrderSend erreur %d",GetLastError());     // en cas d'erreur d'envoi de la demande, affiche le code d'erreur
         request.type_filling =SYMBOL_FILLING_FOK;
         if(!OrderSend(request,result))
           {
            PrintFormat("OrderSend erreur %d",GetLastError());     // en cas d'erreur d'envoi de la demande, affiche le code d'erreur
           }
        }
      //--- informations de l'opération
      PrintFormat("retcode=%u  transaction=%I64u  ordre=%I64u",result.retcode,result.deal,result.order);

      if(result.retcode == TRADE_RETCODE_DONE && result.order != 0)
         break;
     }
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MODE_TRADE_SIGNAL tradeSignal()
  {
   double close = iClose(gSymbol, PERIOD_CURRENT, 1);
   double open = iOpen(gSymbol, PERIOD_CURRENT, 1);
   double priceToMADist = fabs(currentMA-open)/Point();
   string message;

   //Print("priceToMaDist ", priceToMADist);
//Buy signal
//MA should be between a bullish candle or a bullish candle should be at the right distance to the MA
// and the MA Slope color should be green

   if(close > open && currentColor == 0)
     {
      if((currentMA < close && currentMA > open) || (open > currentMA && InpAlertDistanceToMA >= priceToMADist))
        {
         message = "Potential " + gSymbol + " BUY on " + Period() + " min timeframe";
         Notify(message);
         return BUY_SIGNAL;
        }
     }

//Sell signal
//MA should be between a bearish candle or a bearish candle should be at the right distance to the MA
// and the MA Slope color should be red

   if(close < open && currentColor == 1)
     {
      if((currentMA > close && currentMA < open) || (open < currentMA && InpAlertDistanceToMA >= priceToMADist))
        {
         message = "Potential " + gSymbol + " SELL on " + Period() + " min timeframe";
         Notify(message);
         return SELL_SIGNAL;
        }
     }

   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getAutoStopLoss(ENUM_MODE_TRADE_SIGNAL signal)
  {

   double sl=0.0, low, high;

   for(int i=0; i<InpAutoStopLossCandlesAmount; i++)
     {
      if(signal == BUY_SIGNAL)
        {
         low = iLow(gSymbol, PERIOD_CURRENT, i);
         if(sl == 0.0)
           {
            sl = low;
           }
         else
           {
            if(low < sl)
              {
               sl = low;
              }
           }
        }

      if(signal == SELL_SIGNAL)
        {
         high = iHigh(gSymbol, PERIOD_CURRENT, i);
         if(sl == 0.0)
           {
            sl = high;
           }
         else
           {
            if(high > sl)
              {
               sl = high;
              }
           }
        }
     }
     return sl;
  }
//+------------------------------------------------------------------+
