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



//Enumerative for trading time
enum ENUM_MODE_TRADE_SIGNAL
  {
   BUY_SIGNAL=0,           //Buy trade
   SELL_SIGNAL=1,          //Sell trade
   NO_SIGNAL=2,            //No trade
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
input int InpMaxSpread=15;                                              //Maximum Spread Allowed
input int InpSlippage=1;                                                //Maximum Slippage Allowed in points
input string Comment_01="----------------------";                       //Stop loss settings
input ENUM_MODE_SL InpStopLossMode=SL_FIXED;                            //Stop Loss Mode
input int InpDefaultStopLoss=200;                                       //Default Stop Loss In Points (0=No Stop Loss)
input int InpAutoStopLossCandlesAmount=10;                              //Auto SL amount of candles
input int InpAlertDistanceToMA=50;                                      //Distance to alert
input int InpMinStopLoss=0;                                             //Minimum Allowed Stop Loss In Points
input int InpMaxStopLoss=5000;                                          //Maximum Allowed Stop Loss In Points
input bool InpDisableStopLoss=false;                                    //Disable Stop Loss
input string Comment_02="----------------------";                       //Take profit settings
input ENUM_MODE_TP InpTakeProfitMode=TP_FIXED;                          //Take Profit Mode
input int InpDefaultTakeProfit=60;                                      //Default Take Profit In Points (0=No Take Profit)
input int InpMinTakeProfit=0;                                           //Minimum Allowed Take Profit In Points
input int InpMaxTakeProfit=5000;                                        //Maximum Allowed Take Profit In Points
input double InpTakeProfitPercent=1.0;                                  //Take Profit Multiplier

input string Comment_1="----------------------";                        //	Moving average slope settings
input	int	InpPeriods								=	1000;	                  //	Periods
input	ENUM_MA_METHOD	InpMethod					=	MODE_SMA;	            //	Method
input	ENUM_APPLIED_PRICE	InpAppliedPrice	=	PRICE_CLOSE;	         // Price

input string Comment_2="----------------------";                        // Others
input int InpPriceToMaMarging=100;                                       //Price to MA marging
input string InpComment  = __FILE__;                            //Default trade comment
input int  InpMagicNumber = 198901;                               //Magic Number

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string gSymbol = Symbol();
double bufferMA[3];
double bufferColor[3];
double currentMA, currentColor;
   
int gTotalSellPositions, gTotalBuyPositions, gTotalPositions;

bool gIsPreChecksOk=false;                                              //Indicates if the pre checks are satisfied
bool gIsSpreadOK=false;                                                 //Indicates if the spread is low enough to trade
bool IsSpreadOK=false;                                         //Urgently close losing trade


double gLotSize=InpDefaultLotSize;

int gTickValue=0;
double Spread = 0.0;          //Check the impact. It's originally a double

int gOrderOpRetry = 10;

MqlTick last_tick;
MqlDateTime dt;
//+------------------------------------------------------------------+
