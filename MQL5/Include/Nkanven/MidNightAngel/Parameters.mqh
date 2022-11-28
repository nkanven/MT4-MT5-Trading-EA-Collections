//+------------------------------------------------------------------+
//|                                                   Parameters.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"


//Enumerative for the positioning
enum ENUM_POSITIONING
  {
   STANDARD_BUY=1,
   TWO_SL_BUY=2,
   THREE_SL_BUY=3,
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
   string            time;
   int               type;
   double            profit;
  } lt;

//
//	Input Section
//

input string Comment_0="==========";                                    //Risk Management Settings
input ENUM_RISK_DEFAULT_SIZE InpRiskDefaultSize=RISK_DEFAULT_AUTO;      //Position Size Mode
input double InpDefaultLotSize=1;                                       //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE InpRiskBase=RISK_BASE_BALANCE;                     //Risk Base
input double InpMaxRiskPerTrade=4.5;                                    //Percentage To Risk Each Trade
input double InpMinLotSize=0.01;                                        //Minimum Position Size Allowed
input double InpMaxLotSize=100;                                         //Maximum Position Size Allowed
input int InpMaxSpread=10;                                              //Maximum Spread Allowed
input int InpSlippage=1;                                                //Maximum Slippage Allowed in points
input double InpDefaultSize=1.0;
input double InpOneSlSize=3.77;
input double InpTwoSlSize=7.55;
input ENUM_MODE_SL InpStopLossMode=SL_FIXED;                            //Stop Loss Mode
input int InpDefaultStopLoss=200;                                         //Default Stop Loss In Points (0=No Stop Loss)
input int InpMinStopLoss=0;                                             //Minimum Allowed Stop Loss In Points
input int InpMaxStopLoss=5000;                                          //Maximum Allowed Stop Loss In Points
input ENUM_MODE_TP InpTakeProfitMode=SL_FIXED;                           //Take Profit Mode
input int InpDefaultTakeProfit=60;                                       //Default Take Profit In Points (0=No Take Profit)
input int InpMinTakeProfit=0;                                           //Minimum Allowed Take Profit In Points
input int InpMaxTakeProfit=5000;                                        //Maximum Allowed Take Profit In Points
input double InpTakeProfitPercent=1.0;                                  //Take Profit percent on risk base

input int InpChallengePhase=1;


//	Some standard inputs,
//		remember to change the default magic for each EA
//
input	double	InpVolume		=	0.01;			//	Default order size
input	string	InpComment		=	__FILE__;	//	Default trade comment
input	int		InpMagicNumber	=	198901;	   //	Magic Number

input string Comment_1="==========";                      //Trading Hours Settings
input bool InpUseTradingHours=false;                      //Limit Trading Hours
input string InpTradingHourStart="01";                    //Trading Start Hour (Broker Server Hour)

bool gIsNewCandle=false;
bool gIsTradedThisBar=false;
bool gIsOperatingHours=false;
bool gIsPreChecksOk=false;                 //Indicates if the pre checks are satisfied
bool gIsSpreadOK=false;                    //Indicates if the spread is low enough to trade
bool IsSpreadOK=false;
bool IsLosing=false;


double gLotSize=InpDefaultLotSize;
double gLotMultiplier=InpDefaultSize;

string Symb=Symbol();
string subfolder=AccountInfoInteger(ACCOUNT_LOGIN);
string filename = subfolder+"\\balanceStored.txt";
int gTickValue=0;
long Spread =    SymbolInfoInteger(Symb,SYMBOL_SPREAD) / 100;  //Check the impact. It's originally a double

int gStandardRisk[] = {3, -1, 0, -4};
int gTwoSL = -2;
int gOneSL[] = {1, -3};
int gOrderOpRetry = 10;

string gSymbol = Symbol();

double LotSize=0;

MqlTick last_tick;
MqlDateTime dt;
ENUM_POSITIONING gBuyPositioning=STANDARD_BUY;