//+------------------------------------------------------------------+
//|                                         DL_EntriesManagement.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Evaluate if there is an entry signal
void EvaluateEntry()
  {

   Print("Evaluating entry possibility, In Signal entry "+(string)SignalEntry);
   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
   if(!IsSpreadOK)
     {
      Print("Spread is too high to open a position");
      return;    //If the spread is too high don't give an entry signal
     }
   if(UseTradingHours && !IsOperatingHours)
      return;      //If you are using trading hours and it's not a trading hour don't give an entry signal
//if(!IsNewCandle) return;      //If you want to provide a signal only if it's a new candle opening
//if(IsTradedThisBar) return;   //If you don't want to execute multiple trades in the same bar
   /*
   if(!ShouldTrade())
     {
      Print("No additional trade is allowed on a profitable day");
      return;
     }*/
     
   if(TotalOpenOrders>0)
     {
      Print("Trade activity suspended! Opened position(s) found.");
      return; //If there are already open orders and you don't want to open more
     }

//Entry Signal for BUY orders
   if(iLow(Symb,PERIOD_M5,0) < upper_boundary && last_tick.ask > upper_boundary)
     {
      SignalEntry=SIGNAL_ENTRY_BUY;
      Print("Buy entry signal");
     }

//Entry Signal for SELL orders
   if(iHigh(Symb,PERIOD_M5,0) > lower_boundary && last_tick.bid < lower_boundary)
     {
      SignalEntry=SIGNAL_ENTRY_SELL;
      Print("Sell entry signal");
     }
   Print("Evaluating entry possibility, Out Signal entry "+(string)SignalEntry);
  }



//Execute entry if there is an entry signal
void ExecuteEntry()
  {
//If there is no entry signal no point to continue, exit the function
   if(SignalEntry==SIGNAL_ENTRY_NEUTRAL)
      return;
   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;
//If there is a Buy entry signal
   if(SignalEntry==SIGNAL_ENTRY_BUY)
     {
      Print("In buy execution");
      Operation=ORDER_TYPE_BUY; //Set the operation to BUY
      OpenPrice=last_tick.ask;    //Set the open price to Ask price
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode==SL_FIXED && DefaultStopLoss>0)
        {
         StopLossPrice=OpenPrice-DefaultStopLoss*Point();
        }
      //If the Stop Loss is automatic
      if(StopLossMode==SL_AUTO)
        {
         //Set the Stop Loss to the custom stop loss price
         //StopLossPrice=last_tick.ask-((last_tick.ask-sell_level));
         StopLossPrice=lower_boundary;
        }
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode==TP_FIXED && DefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice+DefaultTakeProfit*Point();
        }
      //If the Take Profit is automatic
      if(TakeProfitMode==TP_AUTO)
        {
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=OpenPrice+(rangeScope*takeprofitpercent);
        }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice);
     }


   if(SignalEntry==SIGNAL_ENTRY_SELL)
     {
      Operation=ORDER_TYPE_SELL; //Set the operation to SELL
      OpenPrice=last_tick.bid;    //Set the open price to Ask price
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode==SL_FIXED && DefaultStopLoss>0)
        {
         StopLossPrice=OpenPrice+DefaultStopLoss*Point();
        }
      //If the Stop Loss is automatic
      if(StopLossMode==SL_AUTO)
        {
         //Set the Stop Loss to the custom stop loss price
         //StopLossPrice=last_tick.bid+((buy_level-last_tick.bid));
         StopLossPrice=upper_boundary;
        }
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode==TP_FIXED && DefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice-DefaultTakeProfit*Point();
        }
      //If the Take Profit is automatic
      if(TakeProfitMode==TP_AUTO)
        {
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=OpenPrice-(rangeScope*takeprofitpercent);
        }
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
         break;

      /*int res=OrderSend(Instrument,Command,LotSize,OpenPrice,Slippage,NormalizeDouble(SLPrice,Digits()),NormalizeDouble(TPPrice,Digits()),OrderNote,MagicNumber,Expiration,OpenColor);
      //If the submission is successful print it in the log and exit the function
      if(res!=-1)
        {
         Print("TRADE - OPEN SUCCESS - Order ",res," submitted: Command ",Command," Volume ",LotSize," Open ",OpenPrice," Stop ",SLPrice," Take ",TPPrice," Expiration ",Expiration);
         break;
        }
      //If the submission failed print the error
      else
        {
         Print("TRADE - OPEN FAILED - Order ",res," submitted: Command ",Command," Volume ",LotSize," Open ",OpenPrice," Stop ",SLPrice," Take ",TPPrice," Expiration ",Expiration);
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - NEW - error sending order, return error: ",Error," - ",ErrorText);
        }*/
     }
   return;
  }
//+------------------------------------------------------------------+
