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
   if(isPinBar()==NO_SIGNAL)
      return;

   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;

//Place market order
   if(isPinBar() == BUY_SIGNAL)
     {

      OpenPrice=last_tick.ask;    //Set the open price to Ask price

      //If the Stop Loss is fixed and the default stop loss is set
      if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0)
        {
         StopLossPrice=OpenPrice-(InpDefaultStopLoss*Point());
        }

      //If the Stop Loss is set to automatic
      if(InpStopLossMode==SL_AUTO)
        {
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=OpenPrice - (gAtr*InpAtrMultiplier);
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
         TakeProfitPrice=OpenPrice+((gAtr*InpAtrMultiplier)*InpTakeProfitPercent);
        }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_BUY,gSymbol,OpenPrice,StopLossPrice,TakeProfitPrice);

     }

   if(isPinBar() == SELL_SIGNAL)
     {

      OpenPrice=last_tick.bid;    //Set the open price to Ask price

      //InpAtrMultiplier

      //If the Stop Loss is fixed and the default stop loss is set
      if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0)
        {
         StopLossPrice=OpenPrice+(InpDefaultStopLoss*Point());
        }

      //If the Stop Loss is set to automatic
      if(InpStopLossMode==SL_AUTO)
        {
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=OpenPrice + (gAtr*InpAtrMultiplier);
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
         TakeProfitPrice=OpenPrice-((gAtr*InpAtrMultiplier)*InpTakeProfitPercent);
        }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_SELL,gSymbol,OpenPrice,StopLossPrice,TakeProfitPrice);
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
ENUM_MODE_TRADE_SIGNAL isPinBar()
  {
   double high = iHigh(gSymbol, InpTimeFrame, 1);
   double low = iLow(gSymbol, InpTimeFrame, 1);
   double open = iOpen(gSymbol, InpTimeFrame, 1);
   double close = iClose(gSymbol, InpTimeFrame, 1);

   double candleLength = (high - low) / _Point;
   Print("No point candle length ", (high - low));
   double downBullCandleWick, upBullCandleWick, downBearCandleWick, upBearCandleWick;

   if(candleLength < InpMinCandleLenght)
     {
      return NO_SIGNAL;
     }

//If it's a bullish candle
   if(open < close)
     {
      //If open is equal to low or close is equal to low
      if(open == low || close == low)
        {
         return NO_SIGNAL;
        }

      //There's no buy opened position
      if(gTotalBuyPositions == 0)
        {
         //Compute hammer wick percentage
         downBullCandleWick = (((open - low)/_Point)*100)/candleLength;

         //Wick percent is greater or equal to input wick percentage
         if(downBullCandleWick >= InpCandleWickPercent)
           {
            Print("Buy candleLength ", candleLength, " wick if downBullCandleWick ", downBullCandleWick, " percent");
            return BUY_SIGNAL;
           }
        }

      if(gTotalSellPositions == 0)
        {
         upBullCandleWick = (((high - close)/_Point)*100)/candleLength;
         if(upBullCandleWick >= InpCandleWickPercent)
           {
            Print("Buy candleLength ", candleLength, " wick if upBullCandleWick ", upBullCandleWick, " percent");
            return SELL_SIGNAL;
           }
        }
     }

//if it's a bearich candle
   if(open > close)
     {
      //If high is equal to close or high is equal to open
      if(high == close || high == open)
        {
         return NO_SIGNAL;
        }

      if(gTotalSellPositions == 0)
        {
         upBearCandleWick = (((high - open)/_Point)*100)/candleLength;
         if(upBearCandleWick >= InpCandleWickPercent)
           {
            Print("Sell candleLength ", candleLength, " wick if upBearCandleWick ", upBearCandleWick, " percent");
            return SELL_SIGNAL;
           }
        }

      //There's no buy opened position
      if(gTotalBuyPositions == 0)
        {
         //Compute hammer wick percentage
         downBearCandleWick = (((close - low)/_Point)*100)/candleLength;

         //Wick percent is greater or equal to input wick percentage
         if(downBearCandleWick >= InpCandleWickPercent)
           {
            Print("Buy candleLength ", candleLength, " wick if downBearCandleWick ", downBearCandleWick, " percent");
            return BUY_SIGNAL;
           }
        }
     }
   Print("No pin bar");
   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
