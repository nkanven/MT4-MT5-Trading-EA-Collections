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
   if(isTradingOpportunity()==NO_SIGNAL)
      return;

   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;

//Place market order
   if(isTradingOpportunity() == BUY_SIGNAL && gTotalBuyPositions == 0)
     {

      OpenPrice=last_tick.ask;    //Set the open price to Ask price

      //If the Stop Loss is fixed and the default stop loss is set
      if(InpDefaultStopLoss>0)
        {
         StopLossPrice=OpenPrice-(InpDefaultStopLoss*Point());
        }


      //If the Take Profix price is fixed and defined
      if(InpDefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice+InpDefaultTakeProfit*Point();
        }

      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_BUY,InpInstrument1,OpenPrice,StopLossPrice,TakeProfitPrice);
      SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_BUY,InpInstrument2,blast_tick.ask);

     }

   if(isTradingOpportunity() == SELL_SIGNAL && gTotalSellPositions == 0)
     {

      OpenPrice=last_tick.bid;    //Set the open price to Ask price

      //InpAtrMultiplier

      //If the Stop Loss is fixed and the default stop loss is set
      if(InpDefaultStopLoss>0)
        {
         StopLossPrice=OpenPrice+(InpDefaultStopLoss*Point());
        }

      //If the Take Profix price is fixed and defined
      if(InpDefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice-InpDefaultTakeProfit*Point();
        }

      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_SELL,InpInstrument1,OpenPrice,StopLossPrice,TakeProfitPrice);
      SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_SELL,InpInstrument2,blast_tick.bid);
     }
  }

//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int action, int Command, string Instrument, double OpenPrice, double SLPrice=0, double TPPrice=0, datetime Expiration=0)
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
ENUM_MODE_TRADE_SIGNAL isTradingOpportunity()
  {
   double open = 0.0, close = 0.0;
   int bullishCandle = 0, bearichCandle = 0, sameCandleCount = -InpSameCandleCount;

   for(int i=1; i<=InpSameCandleCount; i++)
     {

      Print("counting candles - ", i);
      open = iOpen(gSymbol, InpTimeFrame, i);
      close = iClose(gSymbol, InpTimeFrame, i);

      Print("Open ", open," close ", close);

      if(open < close)
        {
         bullishCandle += 1;
        }
      if(open > close)
        {
         bearichCandle -= 1;
        }
     }

   Print("bullishCandle ", bullishCandle, " bearichCandle ", bearichCandle);

   if(bullishCandle == InpSameCandleCount && open > gSma)
     {
      return BUY_SIGNAL;
     }

   if(bearichCandle == sameCandleCount && gSma > open)
     {
      return SELL_SIGNAL;
     }
   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+

