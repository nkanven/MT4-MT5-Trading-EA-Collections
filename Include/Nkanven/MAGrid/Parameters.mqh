//+------------------------------------------------------------------+
//|                                                   Parameters.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Enumerative for the entry signal value
enum ENUM_SIGNAL_ENTRY
  {
   SIGNAL_ENTRY_NEUTRAL=0,    //SIGNAL ENTRY NEUTRAL
   SIGNAL_ENTRY_ENTER=1,        //SIGNAL PENDING BUY/SELL
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

//Enumerative for candle type
enum ENUM_CANDLE_TYPE
  {
   NEUTRAL_CANDLE=0,
   BEARISH_CANDLE=1,
   BULLISH_CANDLE=2,
  };

//Enumerative for price momentum
enum  ENUM_PRICE_MOMENTUM
  {
   UP=2,
   DOWN=1,
   NEUTRAL=0,
  };

struct LastTransaction
  {
   string            time;
   int               type;
   double            profit;
  } lt;

//
//	Input Section
//
//	Fast moving average
input	int	InpFastPeriods								=	200;	//	Fast periods
input	ENUM_MA_METHOD	InpFastMethod					=	MODE_SMA;	//	Fast method
input	ENUM_APPLIED_PRICE	InpFastAppliedPrice	=	PRICE_CLOSE;	// Fast price

/*	Slow moving average
input	int	InpSlowPeriods								=	20;	//	Slow periods
input	ENUM_MA_METHOD	InpSlowMethod					=	MODE_SMA;	//	Slow method
input	ENUM_APPLIED_PRICE	InpSlowAppliedPrice	=	PRICE_CLOSE;	// Slow price
*/
input int   InpAtrPeriod                        = 14;    // ATR period
//	Bar numbers for comparison
//input	int	InpBar2									=	2;	   //	Base bar number
//input	int	InpBar1									=	1;	   //	Crossover bar number

input string Comment_0="==========";                                 //Risk Management Settings
input ENUM_RISK_DEFAULT_SIZE InpRiskDefaultSize=RISK_DEFAULT_AUTO;      //Position Size Mode
input double InpDefaultLotSize=1;                                       //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE InpRiskBase=RISK_BASE_BALANCE;                     //Risk Base
input double InpMaxRiskPerTrade=0.5;                                    //Percentage To Risk Each Trade
input double InpMinLotSize=0.01;                                        //Minimum Position Size Allowed
input double InpMaxLotSize=100;                                         //Maximum Position Size Allowed
input int InpMaxSpread=20;                                         //Maximum Spread Allowed
input int InpSlippage=5;                                                //Maximum Slippage Allowed in points
input ENUM_MODE_SL InpStopLossMode=SL_AUTO;                            //Stop Loss Mode
input int InpDefaultStopLoss=0;                                         //Default Stop Loss In Points (0=No Stop Loss)
input int InpMinStopLoss=0;                                             //Minimum Allowed Stop Loss In Points
input int InpMaxStopLoss=5000;                                          //Maximum Allowed Stop Loss In Points
input bool InpAtrStopLoss=false;                                        //Set Stop loss based on ATR
input int InpAtrMultiplier=3;                                           //Multiplicator for ATR
input ENUM_MODE_TP InpTakeProfitMode=TP_AUTO;                           //Take Profit Mode
input int InpDefaultTakeProfit=0;                                       //Default Take Profit In Points (0=No Take Profit)
input int InpMinTakeProfit=0;                                           //Minimum Allowed Take Profit In Points
input int InpMaxTakeProfit=5000;                                        //Maximum Allowed Take Profit In Points
input double InpTakeProfitPercent=1.0;                                  //Take Profit percent on risk base

// Trading time
input int  InStartHour                          =  12;    // Trading starting hour
input int  InStartMin                           =  30;    // Trading starting minute
input int  InEndHour                            =  12;    // Trading starting hour
input int  InEndMin                             =  30;    // Trading starting minute

//
//	Some standard inputs,
//		remember to change the default magic for each EA
//
input	double	InpVolume		=	0.01;			//	Default order size
input	string	InpComment		=	__FILE__;	//	Default trade comment
input	int		InpMagicNumber	=	198901;	   //	Magic Number

input string Comment_1="==========";                      //Trading Hours Settings
input bool InpUseTradingHours=false;                      //Limit Trading Hours
input string InpTradingHourStart="01";                    //Trading Start Hour (Broker Server Hour)
input string InpTradingHourEnd="23";                      //Trading End Hour (Broker Server Hour)
input string InpTradingStartMin="30";                     //Trading Start minute (Broker Server Hour)
input string InpTradingEndMin="00";                       //Trading End minute

bool gIsNewCandle=false;
bool gIsTradedThisBar=false;
bool gIsOperatingHours=false;
bool gIsPreChecksOk=false;                 //Indicates if the pre checks are satisfied
bool gIsSpreadOK=false;                    //Indicates if the spread is low enough to trade

double gLotSize=InpDefaultLotSize;
int gTickValue=0;

int gTotalBuyPositions=0;
int gTotalSellPositions=0;
int gTotalPositions=0;
int gTotalOpenOrders=0;
int gOrderOpRetry=5;
int gTotalTransactions=0;
double gBuyStopLossPrice;
double gSellStopLossPrice;
double gBuyEntryPrice;
double gSellEntryPrice;
double gAtr;

string gSymbol = Symbol();

datetime gLastBarTraded=NULL;

double gMa;
double LotSize=0;

MqlTick last_tick;
MqlDateTime dt;

ENUM_SIGNAL_ENTRY gSignalEntry=SIGNAL_ENTRY_NEUTRAL;      //Entry signal variable
ENUM_SIGNAL_EXIT gSignalExit=SIGNAL_EXIT_NEUTRAL;