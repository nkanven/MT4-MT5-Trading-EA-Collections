//+------------------------------------------------------------------+
//|                                                       LotCal.mq4 |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin/in/nkondog.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin/in/nkondog.com "
#property version   "2.00"  //Handle take profit ant dymanic horizontal line price detection
#property strict

#define KEY_B             66
#define KEY_S             83

//Parameters

//Enumerative for the base used for risk calculation
enum ENUM_RISK_BASE
  {
   RISK_BASE_EQUITY=1,        //EQUITY
   RISK_BASE_BALANCE=2,       //BALANCE
   RISK_BASE_FREEMARGIN=3,    //FREE MARGIN
   RISK_BASE_INPUT=4,         //INPUT BASE
  };

//Enumerative for the default risk size
enum ENUM_RISK_DEFAULT_SIZE
  {
   RISK_DEFAULT_FIXED=1,      //FIXED SIZE
   RISK_DEFAULT_AUTO=2,       //AUTOMATIC SIZE BASED ON RISK
  };

input ENUM_RISK_DEFAULT_SIZE InpRiskDefaultSize=RISK_DEFAULT_AUTO;      //Position Size Mode
input double InpBalance=10000.0;                                        //Balance
input double InpDefaultLotSize=0.01;                                    //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE InpRiskBase=RISK_BASE_BALANCE;                     //Risk Base
input double InpMaxRiskPerTrade=0.5;                                    //Percentage To Risk Each Trade
input double InpTPMultiple=1;                                           //TP multiple %
input double InpMinLotSize=0.01;                                        //Minimum Position Size Allowed
input double InpMaxLotSize=100;                                         //Maximum Position Size Allowedv

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Symb = Symbol();
double LotSize=InpDefaultLotSize;
double stopLoss=0.0;
double TakeProfit=0.0;
double risk=0.0;
double StoplossPips=0.0;
//TickValue is the value of the individual price increment for 1 lot of the instrument, expressed in the account currenty
double TickValue=SymbolInfoDouble(Symb,SYMBOL_TRADE_TICK_VALUE);
int ticket;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print("The Expert Advisor with name ",MQLInfoString(MQL_PROGRAM_NAME)," is running");
//--- enable object create events
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_CREATE,true);
//--- enable object delete events
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_DELETE,true);
//---
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   stopLoss = NormalizeDouble(ObjectGetDouble(0, "sl", OBJPROP_PRICE), _Digits);
   displayOnChart();
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event identifier
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
  {
//--- the object has been deleted
   if(id==CHARTEVENT_OBJECT_DELETE)
     {
      Print("The object with name ",sparam," has been deleted");
     }
//--- the object has been created
   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      Print("The object with name ",sparam," has been created");
     }

   /*--- the object has been moved or its anchor point coordinates has been changed
      if(id==CHARTEVENT_OBJECT_DRAG)
        {
         price = ObjectGetDouble(0, sparam, OBJPROP_PRICE, 0);
         //Print("The anchor point coordinates of the object with name ",sparam," has been changed. Price ", price);
         displayOnChart();
        }*/

   if(id==CHARTEVENT_KEYDOWN)
     {
      switch(lparam)
        {
         case  KEY_B:
            ///SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_BUY,Symb,last_tick.ask,price,LotSize);
            ticket = OrderSend(Symb, OP_BUY, LotSize, Ask, 1, stopLoss, TakeProfit);
            Alert("Buy " + (string)LotSize + " lot " + Symb + " at " + (string)Ask + " SL at " + (string)stopLoss);
            break;
         case  KEY_S:
            ticket = OrderSend(Symb, OP_SELL, LotSize, Bid, 1, stopLoss,TakeProfit);
            Alert("Sell " + (string)LotSize + " lot " + Symb + " at " + (string)Bid + " SL at " + (string)stopLoss);
            break;
         default:
            //Print("Do nothing");
            break;
        }

      if(ticket<=0)
        {
         int error=GetLastError();
         //---- not enough money
         //if(error==134);
         //---- 10 seconds wait
         Sleep(10000);
         //---- refresh price data
         RefreshRates();
        }
      else
        {
         OrderSelect(ticket,SELECT_BY_TICKET);
         OrderPrint();
        }
     }
  }


//Lot Size Calculator
void LotSizeCalculate(double sLoss)
  {
   double SL=0;
   double PriceAsk=MarketInfo(0,MODE_ASK);
   double PriceBid=MarketInfo(0,MODE_BID);
   double spread = MarketInfo(0,MODE_SPREAD) * _Point;
   double pipDiff = 0.0;

   if(sLoss < PriceAsk)
     {
      pipDiff = PriceAsk-sLoss;
      SL = (PriceAsk-sLoss)/_Point;
      //Print("TakeProfit ", TakeProfit, " PriceAsk ", PriceAsk, " pipDiff ", pipDiff, " InpTPMultiple ", InpTPMultiple, " spread ", spread);
      TakeProfit = PriceAsk + (pipDiff * InpTPMultiple) + (spread*2);
     }
   if(sLoss > PriceAsk)
     {
      pipDiff = sLoss-PriceBid;
      SL = (sLoss-PriceBid)/_Point;
      //Print("TakeProfit ", TakeProfit, " PriceAsk ", PriceBid, " pipDiff ", pipDiff, " InpTPMultiple ", InpTPMultiple, " spread ", spread);
      TakeProfit = PriceBid - (pipDiff * InpTPMultiple) - (spread*2);
     }

   TakeProfit = NormalizeDouble(TakeProfit, _Digits);
//Print("Stop loss distance ", SL);

//If the position size is dynamic
   if(InpRiskDefaultSize==RISK_DEFAULT_AUTO)
     {
      //If the stop loss is not zero then calculate the lot size
      if(SL!=0)
        {
         double RiskBaseAmount=0;
         //Define the base for the risk calculation depending on the parameter chosen
         if(InpRiskBase==RISK_BASE_BALANCE)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_BALANCE);
         if(InpRiskBase==RISK_BASE_EQUITY)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_EQUITY);
         if(InpRiskBase==RISK_BASE_FREEMARGIN)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_FREEMARGIN);
         if(InpRiskBase==RISK_BASE_INPUT)
            RiskBaseAmount=InpBalance;

         //Calculate the Position Size
         //Print("RiskBaseAmount ", RiskBaseAmount, " MaxRiskPerTrade ", InpMaxRiskPerTrade, "Stop loss ", SL, " TickValue ", TickValue);

         LotSize=((RiskBaseAmount*InpMaxRiskPerTrade/100)/(SL*TickValue));
         StoplossPips = SL;
        }
      //If the stop loss is zero then the lot size is the default one
      if(SL==0)
        {
         LotSize=InpDefaultLotSize;
        }
     }
//Normalize the Lot Size to satisfy the allowed lot increment and minimum and maximum position size
   LotSize=MathFloor(LotSize/SymbolInfoDouble(Symb,SYMBOL_VOLUME_STEP))*SymbolInfoDouble(Symb,SYMBOL_VOLUME_STEP);

//Limit the lot size in case it is greater than the maximum allowed by the user
   if(LotSize>InpMaxLotSize)
      LotSize=InpMaxLotSize;
//Limit the lot size in case it is greater than the maximum allowed by the broker
   if(LotSize>SymbolInfoDouble(Symb,SYMBOL_VOLUME_MAX))
      LotSize=SymbolInfoDouble(Symb,SYMBOL_VOLUME_MAX);
//Print("Lot ", LotSize, " Max lot ", SymbolInfoDouble(Symb,SYMBOL_VOLUME_MAX));
//If the lot size is too small then set it to 0 and don't trade
   if(LotSize < SymbolInfoDouble(Symb,SYMBOL_VOLUME_MIN))
     {
      LotSize=0;
      //Print("Lot size too small");
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayOnChart()
  {

   LotSizeCalculate(stopLoss);
//Comment("Lot size : ", LotSize);
   double StopAmount = StoplossPips * LotSize * TickValue;
   string text ="Lot size for "+ (string)InpMaxRiskPerTrade +"% = " + DoubleToString(LotSize,2) + " lot (" + DoubleToString(StopAmount, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) + ")";
   string name = "Lot";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name,text, 14, "Corbel Bold", YellowGreen);
   ObjectSet(name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSet(name, OBJPROP_XDISTANCE, 350);
   ObjectSet(name, OBJPROP_YDISTANCE, 10);

  }
//+------------------------------------------------------------------+
