//+------------------------------------------------------------------+
//|                                            EntriesManagement.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Evaluate if there is an entry signal
void EvaluateEntry()
  {
   if(!gIsSpreadOK)
     {
      Print("At "+SymbolInfoInteger(gSymbol, SYMBOL_SPREAD)+" for "+InpMaxSpread+" Spread is too high to open a position");
      gSignalEntry=SIGNAL_ENTRY_NEUTRAL;
      return;    //If the spread is too high don't give an entry signal
     }
   if(InpUseTradingHours && !gIsOperatingHours)
     {
      gSignalEntry=SIGNAL_ENTRY_NEUTRAL;
      return;      //If you are using trading hours and it's not a trading hour don't give an entry signal
     }
  }

//Execute entry if there is an entry signal
void ExecuteEntry()
  {
//If there is no entry signal no point to continue, exit the function
   if(gSignalEntry==SIGNAL_ENTRY_NEUTRAL)
      return;
   if(last_tick.ask < gMa)
      return;

   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;

   Print("In buy execution");
   Operation=ORDER_TYPE_BUY; //Set the operation to BUY
   OpenPrice=last_tick.ask;    //Set the open price to Ask price
//If the Stop Loss is fixed and the default stop loss is set
   if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0)
     {
      StopLossPrice=OpenPrice-InpDefaultStopLoss*Point();
     }
//If the Stop Loss is automatic
   if(InpStopLossMode==SL_AUTO)
     {
      //Set the Stop Loss to the custom stop loss price
      //StopLossPrice=last_tick.ask-((last_tick.ask-sell_level));
      StopLossPrice=gBuyStopLossPrice;
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
      TakeProfitPrice=OpenPrice+((OpenPrice-StopLossPrice)*InpTakeProfitPercent);
     }
//Normalize the digits for the float numbers
   OpenPrice=NormalizeDouble(OpenPrice,Digits());
   StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
   TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
//Submit the order
   SendOrder(Operation,gSymbol,OpenPrice,StopLossPrice,TakeProfitPrice);

   Operation=ORDER_TYPE_BUY_STOP; //Set the operation to BUY
   SendOrder(Operation,gSymbol,OpenPrice,StopLossPrice,TakeProfitPrice);

   Operation=ORDER_TYPE_BUY_LIMIT; //Set the operation to BUY

   Operation=ORDER_TYPE_SELL_STOP; //Set the operation to SELL
   OpenPrice=gSellEntryPrice;    //Set the open price to Ask price
//If the Stop Loss is fixed and the default stop loss is set
   if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0)
     {
      StopLossPrice=OpenPrice+InpDefaultStopLoss*Point();
     }
//If the Stop Loss is automatic
   if(InpStopLossMode==SL_AUTO)
     {
      StopLossPrice=gSellStopLossPrice;
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
      TakeProfitPrice=OpenPrice-((StopLossPrice-OpenPrice)*InpTakeProfitPercent);
     }
//Normalize the digits for the float numbers
   OpenPrice=NormalizeDouble(OpenPrice,Digits());
   StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
   TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
//Submit the order
   SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice);
  }

//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int Command, string Instrument, double OpenPrice, double SLPrice, double TPPrice, datetime Expiration=0)
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
      if(gLotSize==0)
         return;

      request.action       =TRADE_ACTION_PENDING;                     // type de l'opération de trading
      request.symbol       =Instrument;                              // symbole
      request.volume       =gLotSize;                                   // volume de 0.1 lot
      request.type         =Command;                        // type de l'ordre
      request.price        =OpenPrice; // prix d'ouverture
      request.sl           =NormalizeDouble(SLPrice,Digits());
      request.tp           =NormalizeDouble(TPPrice,Digits());
      request.type_filling =ORDER_FILLING_FOK;
      request.deviation    =InpSlippage;
      request.expiration   =Expiration;                             // déviation du prix autorisée
      //Submit the order

      //Trade.SellStop(mVolume, NormalizeDouble(request.price,mDigits), mSymbol);
      //Trade.BuyStop(mVolume, request.price, mSymbol);

      if(!OrderSend(request,result))
         PrintFormat("OrderSend erreur %d",GetLastError());     // en cas d'erreur d'envoi de la demande, affiche le code d'erreur
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
void entryConditions()
  {
   double motherBarHigh = iHigh(gSymbol, PERIOD_CURRENT, 3);
   double motherBarLow = iLow(gSymbol, PERIOD_CURRENT, 3);

   double firstChildhigh = iHigh(gSymbol, PERIOD_CURRENT, 2);
   double firstChildlow = iLow(gSymbol, PERIOD_CURRENT, 2);

   double secondChildhigh = iHigh(gSymbol, PERIOD_CURRENT, 1);
   double secondChildlow = iLow(gSymbol, PERIOD_CURRENT, 1);

   double candle_high = fabs(motherBarHigh-motherBarLow)*_Point;

   gSignalEntry = SIGNAL_ENTRY_NEUTRAL;

//Check buy candle qualification
   if(motherBarHigh > firstChildhigh && motherBarLow < firstChildlow)
     {
      if(motherBarHigh > secondChildhigh && motherBarLow < secondChildlow)
        {
         Print("Inside bar formed -------------------------------");
         gBuyStopLossPrice = motherBarLow;
         gSellStopLossPrice = motherBarHigh;
         gBuyEntryPrice = motherBarHigh;
         gSellEntryPrice  = motherBarLow;
         gSignalEntry = SIGNAL_ENTRY_ENTER;
        }
     }
  }
//+------------------------------------------------------------------+
