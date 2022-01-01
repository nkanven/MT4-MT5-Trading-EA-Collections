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
   SIGNAL_ENTRY_BUY=1,        //SIGNAL ENTRY BUY
   SIGNAL_ENTRY_SELL=2,        //SIGNAL ENTRY BUY
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
//	Moving average
input	int	InpMAPeriods								=	10;	//	MA Periods
input	ENUM_MA_METHOD	InpMAMethod					=	MODE_SMA;	//	MA Method
input	ENUM_APPLIED_PRICE	InpMAAppliedPrice	=	PRICE_CLOSE;	// MA price


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
input int InpAtrStopLossFactor=3;                                           //Multiplicator for ATR stop loss
input ENUM_MODE_TP InpTakeProfitMode=TP_AUTO;                              //Take Profit Mode
input int InpDefaultTakeProfit=0;                                       //Default Take Profit In Points (0=No Take Profit)
input int InpMinTakeProfit=0;                                           //Minimum Allowed Take Profit In Points
input int InpMaxTakeProfit=5000;                                        //Maximum Allowed Take Profit In Points
input double InpTakeProfitPercent=1.0;                                  //Take Profit percent on risk base

//
//	Some standard inputs,
//		remember to change the default magic for each EA
//
input	double	InpVolume		=	0.01;			//	Default order size
input	string	InpComment		=	__FILE__;	//	Default trade comment
input	int		InpMagicNumber	=	198901;	   //	Magic Number

input string Comment_1="==========";                      //Trading Hours Settings
input bool InpUseTradingHours=false;                      //Limit Trading Hours
input int InpTradingHourStart=1;                    //Trading Start Hour (Broker Server Hour)
input int InpTradingHourEnd=23;                      //Trading End Hour (Broker Server Hour)
input int InpTradingStartMin=30;                     //Trading Start minute (Broker Server Hour)
input int InpTradingEndMin=0;                       //Trading End minute

bool gIsNewCandle=false;
bool gIsTradedThisBar=false;
bool gIsOperatingHours=false;
bool gIsPreChecksOk=false;                 //Indicates if the pre checks are satisfied
bool gIsSpreadOK=false;                    //Indicates if the spread is low enough to trade

double gLotSize=InpDefaultLotSize;
int gTickValue=0;

int gTotalOpenBuy=0;
int gTotalOpenSell=0;
int gTotalOpenOrders=0;
int gTotalOpenPositions=0;
int gOrderOpRetry=5;
double gBuyStopLossPrice, gMinStopLoss;
double gSellStopLossPrice;
double gBuyEntryPrice;
double gSellEntryPrice;
double gPositionOpenPrice, gLastHighestPrice, highestPrice, gPriceChange;

string gSymbol = Symbol();

datetime gLastBarTraded=NULL;

double gSma, gSsma, gHighSma, gLowSma, gPrevSma;
double gCandleHigh, gCandleLow, gCandleOpen, gCandleClose;
double LotSize=0;

long   current_chart_id = ChartID();

MqlTick last_tick;
MqlDateTime dt;

ENUM_SIGNAL_ENTRY gSignalEntry=SIGNAL_ENTRY_NEUTRAL;      //Entry signal variable
ENUM_SIGNAL_EXIT gSignalExit=SIGNAL_EXIT_NEUTRAL;