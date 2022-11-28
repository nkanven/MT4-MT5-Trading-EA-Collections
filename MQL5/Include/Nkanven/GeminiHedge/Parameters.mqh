//+------------------------------------------------------------------+
//|                                                   Parameters.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

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

//Enumerative for trading time
enum ENUM_MODE_TRADING_TIME
  {
   DAY_TRADING=0,            //Day trade
   NIGHT_TRADING=1,          //Night trade
   DAY_NIGHT_TRADING=2,      //Both day & night trade
   ALL_DAY_TRADING=3,        //Round the clock
  };

//Enumerative for trading time
enum ENUM_MODE_TRADE_SIGNAL
  {
   BUY_SIGNAL=0,           //Buy trade
   BUY_STOP_SIGNAL=1,          //Sell trade
   BUY_LIMIT_SIGNAL=2,
   NO_SIGNAL=3,            //No trade
   PENDING_ORDERS=4
  };

//Enumerative for the DCA mode
enum ENUM_DCA_STATUS
  {
   NO_DEALS=0,
   NO_BUY_POSITIONS=1,
   NO_UPPER_BUY_ORDER=2,
   NO_LOWER_BUY_ORDER=3,
   BUY_POSITION_EXISTS=4,
   UPPER_BUY_ORDERS=5,
   LOWER_BUY_ORDERS=6,
   BUY_PENDING_ORDERS=7
  };

//
// Input Section
//

input string Comment_0="==========";                                    //Risk Management Settings

input ENUM_RISK_DEFAULT_SIZE InpRiskDefaultSize=RISK_DEFAULT_AUTO;      //Position Size Mode
input double InpDefaultLotSize=0.01;                                    //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE InpRiskBase=RISK_BASE_BALANCE;                     //Risk Base
input double InpMaxRiskPerTrade=0.5;                                    //Percentage To Risk Each Trade
input double InpMinLotSize=0.01;                                        //Minimum Position Size Allowed
input double InpMaxLotSize=100;                                         //Maximum Position Size Allowed
input int InpMaxSpread=10;                                              //Maximum Spread Allowed
input int InpSlippage=1;                                                //Maximum Slippage Allowed in points
input string Comment_01="----------------------";                       //Stop loss settings
input int InpDefaultStopLoss=200;                                       //Default Stop Loss In Points (0=No Stop Loss)
input int InpMinStopLoss=0;                                             //Minimum Allowed Stop Loss In Points
input int InpMaxStopLoss=5000;                                          //Maximum Allowed Stop Loss In Points
input string Comment_02="----------------------";                       //Take profit settings
input int InpDefaultTakeProfit=100;                                      //Default Take Profit In Points (0=No Take Profit)
input int InpMinTakeProfit=0;                                           //Minimum Allowed Take Profit In Points
input int InpMaxTakeProfit=5000;                                        //Maximum Allowed Take Profit In Points
input double InpTakeProfitPercent=1.0;                                  //Take Profit percent on risk base

input string Comment_03="----------------------";                       //Trading Hours Settings
input bool InpUseTradingHours=false;                                    //Limit Trading Hours
input ENUM_MODE_TRADING_TIME InpTradingPeriods=ALL_DAY_TRADING;         //Select trading periods
input int InpDayTradingHourStart=7;                                     //Day Trading Start Hour (Broker Server Hour)
input int InpDayTradingHourEnd=21;                                      //Day Trading End Hour (Broker Server Hour)
input int InpNightTradingHourStart=1;                                   //Night Trading Start Hour (Broker Server Hour)
input int InpNightTradingHourEnd=5;                                     //Night Trading End Hour (Broker Server Hour)

input string Comment_04="----------------------";                       //DCA settings
input bool InpActivateDCAHedging=true;                                 //Active DCA Hedging
input string InpInstrument1="EURUSD";                                 //Instrument 1
input string InpInstrument2="USDCHF";                                 //Instrument 2
input int InpBuyCallBack=100;                                           //Buy call back pips
input int InpMaxCallBack=10;                                            //Call back limit
input int InpWholePositionTP=0;                                         //Whole position TP percent. 0 to disable

input string Comment_05="----------------------";                       //Stop loss settings
input string InpComment  = __FILE__;                            //Default trade comment
input int  InpMagicNumber = 198901;                               //Magic Number
input ENUM_TIMEFRAMES InpTimeFrame = PERIOD_CURRENT;
input int   InpSameCandleCount= 2;                                //Same Candle in a row

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string gSymbol;

int gTotalBuyOrders, gTotalBuyPositions, gTotalOrders, gTotalPositions;
bool gIsOperatingHours=false;
bool gIsPreChecksOk=false;                                              //Indicates if the pre checks are satisfied
bool gIsSpreadOK=false;                                                 //Indicates if the spread is low enough to trade
bool IsSpreadOK=false;
bool gEmergencyClose=false;                                             //Urgently close losing trade
double gUpOpenPrice, gDownOpenPrice;

double gLotSize=InpDefaultLotSize, point;

int gTickValue=0, lastTicketId;
long Spread;// = SymbolInfoInteger(gSymbol,SYMBOL_SPREAD) / 100;          //Check the impact. It's originally a double

int gOrderOpRetry = 1;

MqlTick last_tick, blast_tick;
MqlDateTime dt;

ENUM_MODE_TRADE_SIGNAL signal = NO_SIGNAL;
//+------------------------------------------------------------------+
