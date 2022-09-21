//+------------------------------------------------------------------+
//|                                           StarRiskCalculator.mq5 |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin.com/in/nkondog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin.com/in/nkondog"
#property version   "1.00"


//Parameters
MqlTick last_tick;
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
input double InpMaxLossPercent=4.0;                                     //Max Account Risk %
input int InpLifeCount=20;                                              //Number of losses
double InpDefaultLotSize=0.01;                                          //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE InpRiskBase=RISK_BASE_BALANCE;                     //Risk Base
//input double InpMaxRiskPerTrade=0.5;                                    //Percentage To Risk Each Trade
double InpMinLotSize=0.01;                                              //Minimum Position Size Allowed
double InpMaxLotSize=100;                                               //Maximum Position Size Allowed
double RiskBaseAmount=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Symb = Symbol();
string AccountCurr = AccountInfoString(ACCOUNT_CURRENCY);
double MaxRiskPerTrade=0.0;                                    //Percentage To Risk Each Trade
double LotSize=InpDefaultLotSize;
double price=0.0;
double risk=0.0;
double StoplossPips=0.0;
double riskDiff=0.0;
double initialLoss=0.0;
double totalLoss=0.0;
double maxRiskPerLife=0.0;

//TickValue is the value of the individual price increment for 1 lot of the instrument, expressed in the account currenty
double TickValue=SymbolInfoDouble(Symb,SYMBOL_TRADE_TICK_VALUE);

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
   
   LotSizeCalculate(price);
   riskDiff = NormalizeDouble(RiskBaseAmount - InpBalance, 2);
   initialLoss = (InpBalance * InpMaxLossPercent) / 100;
   totalLoss = NormalizeDouble(riskDiff + initialLoss, 2);
   maxRiskPerLife = NormalizeDouble(totalLoss /InpLifeCount, 2);
   MaxRiskPerTrade = NormalizeDouble((maxRiskPerLife * 100) / RiskBaseAmount, 2);
   
   Comment("Star Risk Calculator \nRiskDiff: " + riskDiff + " " + AccountCurr +"\nInitialLoss: " + initialLoss + " " + AccountCurr +"\nTotalLoss: " + totalLoss + " " + AccountCurr +"\nMaxRiskPerLife: " + maxRiskPerLife + " " + AccountCurr + "\nMaxRiskPerTrade: " + MaxRiskPerTrade +"%");
   
   
double StopAmount = StoplossPips * LotSize * TickValue;

   string text ="Lot size for "+ MaxRiskPerTrade +"% = " + DoubleToString(LotSize,2) + " lot (" + NormalizeDouble(StopAmount, 2) + " " + AccountCurr + ")";
   string name = "Lot";
   string name2 = "risk";
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   //ObjectSetText(name,text, 36, "Corbel Bold", YellowGreen);
   ObjectSetInteger(0,name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0,name, OBJPROP_YDISTANCE, 10);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,14);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrYellowGreen);
   //LabelDelete(0, name);
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

//--- the object has been moved or its anchor point coordinates has been changed
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      price = ObjectGetDouble(0, sparam, OBJPROP_PRICE, 0);
      Print("The anchor point coordinates of the object with name ",sparam," has been changed. Price ", price);
     }
  }


//Lot Size Calculator
void LotSizeCalculate(double stopLoss)
  {
  SymbolInfoTick(_Symbol,last_tick);
   double SL=0;
   double PriceAsk=last_tick.ask;
   double PriceBid=last_tick.bid;

   if(stopLoss < PriceAsk)
     {
      SL = (PriceAsk-stopLoss)/_Point;
     }
   if(stopLoss > PriceAsk)
     {
      SL = (stopLoss-PriceBid)/_Point;
     }
   Print("Stop loss distance ", SL);

//If the position size is dynamic
   if(InpRiskDefaultSize==RISK_DEFAULT_AUTO)
     {
      //If the stop loss is not zero then calculate the lot size
      if(SL!=0)
        {
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

         LotSize=((RiskBaseAmount*MaxRiskPerTrade/100)/(SL*TickValue));
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
   Print("Lot ", LotSize, " Max lot ", SymbolInfoDouble(Symb,SYMBOL_VOLUME_MAX));
//If the lot size is too small then set it to 0 and don't trade
   if(LotSize < SymbolInfoDouble(Symb,SYMBOL_VOLUME_MIN))
     {
      LotSize=0;
      Print("Lot size too small");
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Delete a text label                                              |
//+------------------------------------------------------------------+
bool LabelDelete(const long   chart_ID=0,   // chart's ID
                 const string name="Label") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }