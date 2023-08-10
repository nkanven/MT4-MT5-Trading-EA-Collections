//+------------------------------------------------------------------+
//|                                                   parameters.mqh |
//|                       Copyright 2023, Nkondog Anselme Venceslas. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Nkondog Anselme Venceslas."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

//-ENUMERATIVE VARIABLES-//
//Enumerative variables are useful to associate numerical values to easy to remember strings
//It is similar to constants but also helps if the variable is set from the input page of the EA
//The text after the // is what you see in the input paramenters when the EA loads
//It is good practice to place all the enumberative at the start

//Enumerative for the entry signal value
enum ENUM_SIGNAL_ENTRY
  {
   SIGNAL_ENTRY_NEUTRAL=0,    //SIGNAL ENTRY NEUTRAL
   SIGNAL_ENTRY_BUY=1,        //SIGNAL ENTRY BUY
   SIGNAL_ENTRY_SELL=-1,      //SIGNAL ENTRY SELL
  };

//Enumerative for the exit signal value
enum ENUM_SIGNAL_EXIT
  {
   SIGNAL_EXIT_NEUTRAL=0,     //SIGNAL EXIT NEUTRAL
   SIGNAL_EXIT_BUY=1,         //SIGNAL EXIT BUY
   SIGNAL_EXIT_SELL=-1,       //SIGNAL EXIT SELL
   SIGNAL_EXIT_ALL=2,         //SIGNAL EXIT ALL
  };

//Enumerative for the allowed trading direction
enum ENUM_TRADING_ALLOW_DIRECTION
  {
   TRADING_ALLOW_BOTH=0,      //ALLOW BOTH BUY AND SELL
   TRADING_ALLOW_BUY=1,       //ALLOW BUY ONLY
   TRADING_ALLOW_SELL=-1,     //ALLOW SELL ONLY
  };

//Enumerative for the base used for risk calculation
enum ENUM_RISK_BASE
  {
   RISK_BASE_EQUITY=1,        //EQUITY
   RISK_BASE_BALANCE=2,       //BALANCE
   RISK_BASE_FREEMARGIN=3,    //FREE MARGIN
  };

//Enumerative for the default risk size
enum ENUM_RISK_DEFAULT_SIZE
  {
   RISK_DEFAULT_FIXED=1,      //FIXED SIZE
   RISK_DEFAULT_AUTO=2,       //AUTOMATIC SIZE BASED ON RISK
  };

//Enumerative for the Stop Loss mode
enum ENUM_MODE_SL
  {
   SL_FIXED=0,                //FIXED STOP LOSS
   SL_AUTO=1,                 //AUTOMATIC STOP LOSS
  };

//Enumerative for the Take Profit Mode
enum ENUM_MODE_TP
  {
   TP_FIXED=0,                //FIXED TAKE PROFIT
   TP_AUTO=1,                 //AUTOMATIC TAKE PROFIT
  };

//Enumerative for the stop loss calculation
enum ENUM_MODE_SL_BY
  {
   SL_BY_POINTS=0,            //STOP LOSS PASSED IN POINTS
   SL_BY_PRICE=1,             //STOP LOSS PASSED BY PRICE
  };

struct LastTransaction
  {
   string time;
   int type;
   double profit;
  }lt;

//-INPUT PARAMETERS-//
//The input parameters are the ones that can be set by the user when launching the EA
//If you place a comment following the input variable this will be shown as description of the field

//This is where you should include the input parameters for your entry and exit signals
input string Comment_strategy="==========";                          //Entry And Exit Settings
//Add in this section the parameters for the indicators used in your entry and exit

//General input parameters
input string Comment_0="==========";                                 //Risk Management Settings
input ENUM_RISK_DEFAULT_SIZE RiskDefaultSize=RISK_DEFAULT_AUTO;      //Position Size Mode
input double DefaultLotSize=1;                                       //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE RiskBase=RISK_BASE_BALANCE;                     //Risk Base
input double MaxRiskPerTrade=0.5;                                    //Percentage To Risk Each Trade
input double MinLotSize=0.01;                                        //Minimum Position Size Allowed
input double MaxLotSize=100;                                         //Maximum Position Size Allowed

input string Comment_2="==========";                                //Stop Loss And Take Profit Settings
input ENUM_MODE_SL StopLossMode=SL_AUTO;                            //Stop Loss Mode
input double MinStopLoss = 10.0;                                    //Minimum Stop Loss
input double StopLoss=10.0;                                        //Stop Loss In Points (0=No Take Stop loss)
input bool AtrStopLoss=false;                                       //Set Stop loss based on ATR. If true, StopLoss will be ignored
input int atr_sl_factor=3;                                          //Multiplicator for ATR stop loss if AtrStopLoss if true
input ENUM_MODE_TP TakeProfitMode=TP_AUTO;                          //Take Profit Mode
input double TakeProfit=10.0;                                      //Take Profit In Points (0=No Take Profit)
input double TakeProfitPercent=1.0;                                 //Take Profit percent on risk base

input string Comment_4="==========";                                 //Additional Settings
input int MagicNumber=1987;                                             //Magic Number For The Orders Opened By This EA
input string OrderNote="";                                           //Comment For The Orders Opened By This EA
input int Slippage=5;                                                //Slippage in points
input double MaxSpread=10.0;                                             //Maximum Allowed Spread To Trade In Points

input string Comment_5="===========";                                //Ichimoku indicator setting
input int tenkan_sen=9;                                              //Tenkan-sen
input int kijun_sen=26;                                              //Kijun-sen
int senkou_span_b=52;                                          //Senkou Span B

//-GLOBAL VARIABLES-//
//The variables included in this section are global, hence they can be used in any part of the code
string Symb=Symbol(), server_time;

long   current_chart_id = ChartID();

bool IsPreChecksOk=false;                 //Indicates if the pre checks are satisfied
bool IsNewCandle=false;                   //Indicates if this is a new candle formed
bool IsSpreadOK=false;                    //Indicates if the spread is low enough to trade
bool IsOperatingHours=false;              //Indicates if it is possible to trade at the current time (server time)
bool IsTradedThisBar=false;               //Indicates if an order was already executed in the current candle
bool In_Trade = true;                     //Indicates if trade range has been formed
bool CanBuy = true;
bool CanSell = true;
bool ClosePosition = false;
bool FollowProfit = false;
bool UpTrendingMarket = false;
bool DownTrendingMarket = false;

double TickValue=0;                       //Value of a tick in account currency at 1 lot
double LotSize=0;                         //Lot size for the position
double Tick_Size = SymbolInfoDouble(Symb,SYMBOL_TRADE_TICK_SIZE); //Tick size
double High[];
double Low[];
double PositionProfit;

//Indicators
double TenkansenArray[],
       KijunsenArray[],
       SenkouspanaArray[],
       SenkouspanbArray[],
       ChinkouspanArray[];                       //Create an array for the tenkansan price data

double Tenkansen, Kijunsen, Senkouspana, signal_tenkan, signal_kijun, close_1, close_2, close_3, open_1, open_2, open_3, high_3;
double AdxMain, AdxPlus, AdxMinus;
double Atr;
double rangeUpdated;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Spread =    SymbolInfoInteger(Symb,SYMBOL_SPREAD) / 100;  //Check the impact. It's originally a double
int OrderOpRetry=10;                      //Number of attempts to retry the order submission
int TotalOpenOrders=0;                    //Number of total open orders
int TotalOpenBuy=0;                       //Number of total open buy orders
int TotalOpenSell=0;                      //Number of total open sell orders
int StopLossBy=SL_BY_POINTS;              //How the stop loss is passed for the lot size calculation
int lotMultiplier =1;                        //Adust lot size according to loosing trades

datetime LastBarTraded;

MqlDateTime dt;
MqlTick last_tick;

ENUM_SIGNAL_ENTRY SignalEntry=SIGNAL_ENTRY_NEUTRAL;      //Entry signal variable
ENUM_SIGNAL_EXIT SignalExit=SIGNAL_EXIT_NEUTRAL;
//+------------------------------------------------------------------+
