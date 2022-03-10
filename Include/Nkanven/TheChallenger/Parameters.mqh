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
   SELL_SIGNAL=1,          //Sell trade
   NO_SIGNAL=2,            //No trade
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

input string Comment_0="==========";                                    //Risk Management Settings
input	double	InpVolume		=	0.01;			                           //Default order size

input ENUM_RISK_DEFAULT_SIZE InpRiskDefaultSize=RISK_DEFAULT_AUTO;      //Position Size Mode
input double InpDefaultLotSize=1;                                       //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE InpRiskBase=RISK_BASE_BALANCE;                     //Risk Base
input double InpMaxRiskPerTrade=0.5;                                    //Percentage To Risk Each Trade
input double InpMinLotSize=0.01;                                        //Minimum Position Size Allowed
input double InpMaxLotSize=100;                                         //Maximum Position Size Allowed
input int InpMaxSpread=10;                                              //Maximum Spread Allowed
input int InpSlippage=1;                                                //Maximum Slippage Allowed in points
input ENUM_MODE_SL InpStopLossMode=SL_FIXED;                            //Stop Loss Mode
input int InpDefaultStopLoss=200;                                       //Default Stop Loss In Points (0=No Stop Loss)
input int InpMinStopLoss=0;                                             //Minimum Allowed Stop Loss In Points
input int InpMaxStopLoss=5000;                                          //Maximum Allowed Stop Loss In Points
input ENUM_MODE_TP InpTakeProfitMode=TP_FIXED;                          //Take Profit Mode
input int InpDefaultTakeProfit=60;                                      //Default Take Profit In Points (0=No Take Profit)
input int InpMinTakeProfit=0;                                           //Minimum Allowed Take Profit In Points
input int InpMaxTakeProfit=5000;                                        //Maximum Allowed Take Profit In Points
input double InpTakeProfitPercent=1.0;                                  //Take Profit percent on risk base

input string Comment_1="=========";                                     //Indicators setting
//	Moving average
input	int	InpPeriods								=	21;	                  //Fast periods
input	ENUM_MA_METHOD	InpMethod					=	MODE_SMA;	            //Fast method
input	ENUM_APPLIED_PRICE	InpAppliedPrice	=	PRICE_CLOSE;	         //Fast price

//	Average True Range
input int   InpAtrPeriod                     = 14;                      //ATR period
input int   InpAtrMultiplier                 = 3;                       //ATR multiplier

input string Comment_2="==========";                      //Trading Hours Settings
input bool InpUseTradingHours=false;                      //Limit Trading Hours
input ENUM_MODE_TRADING_TIME InpTradingPeriods=ALL_DAY_TRADING;              //Select trading periods
input int InpDayTradingHourStart=7;                    //Day Trading Start Hour (Broker Server Hour)
input int InpDayTradingHourEnd=21;                      //Day Trading End Hour (Broker Server Hour)
input int InpNightTradingHourStart=1;                  //Night Trading Start Hour (Broker Server Hour)
input int InpNightTradingHourEnd=5;                    //Night Trading End Hour (Broker Server Hour)
input	string	InpComment		=	__FILE__;	             //Default trade comment
input	int		InpMagicNumber	=	198901;	                //Magic Number

string gSymbol = Symbol();
double gAtr, gMa;

int gTotalSellPositions, gTotalBuyPositions, gTotalPositions;
bool gIsOperatingHours=false;
bool gIsPreChecksOk=false;                 //Indicates if the pre checks are satisfied
bool gIsSpreadOK=false;                    //Indicates if the spread is low enough to trade
bool IsSpreadOK=false;
bool IsLosing=false;


double gLotSize=InpDefaultLotSize;

int gTickValue=0;
long Spread = SymbolInfoInteger(gSymbol,SYMBOL_SPREAD) / 100;  //Check the impact. It's originally a double

int gOrderOpRetry = 10;

double LotSize=0;

MqlTick last_tick;
MqlDateTime dt;

ENUM_MODE_TRADE_SIGNAL gSignalEntry = NO_SIGNAL;