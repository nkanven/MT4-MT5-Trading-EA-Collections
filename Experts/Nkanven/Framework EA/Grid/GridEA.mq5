//+------------------------------------------------------------------+
//|                                                       GridEA.mq5 |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
#property version   "1.01"

#include <Nkanven/Frameworks/GridFramework.mqh>

//
// Input Section
//

//This is where you should include the input parameters for your entry and exit signals
input string Comment_strategy="==========";                          //Entry And Exit Settings
//Add in this section the parameters for the indicators used in your entry and exit

//General input parameters
input string Comment_0="==========";                                    //Risk Management Settings
input ENUM_RISK_DEFAULT_SIZE InpRiskDefaultSize=RISK_DEFAULT_AUTO;      //Position Size Mode
input double InpDefaultLotSize=1;                                       //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE InpRiskBase=RISK_BASE_BALANCE;                     //Risk Base
input double InpMaxRiskPerTrade=0.5;                                    //Percentage To Risk Each Trade
input double InpMinLotSize=0.01;                                        //Min Lot Size
input double InpMaxLotSize=100;                                         //Max Lot Size


input string Comment_1="==========";                                    //Trading Hours Settings
input bool InpUseTradingHours=false;                                    //Activate Trading Hours
input string InpTradingHourStart="01";                                  //Trading Start Hour (Broker Server Hour)
input string InpTradingStartMin="30";                                   //Trading Start minute
input string InpTradingHourEnd="23";                                    //Trading End Hour (Broker Server Hour)
input string InpTradingEndMin="00";                                     //Trading End minute
input bool InpUseTradingSession=true;
input ENUM_TRADING_SESSION InpTradingSession = LONDON_SESSION;          //Trading session

input string Comment_2="==========";                                    //Trading Hours Settings
input int InpGridGap = 1000;

input double   InpVolume      =  0.01;                                  //Default order size
input string   InpComment     =  __FILE__;                              //Default trade comment
input int      InpMagicNumber =  20200701;                              //Magic Number
input int      InpBrokerTimeZoneGMT = 2;                                //Broker timezone from GMT
input int      InpSlippage = 2;                                         //Slippage


int londonSession[] = {7, 17};
int newyorkSession[] = {13, 23};
int tokyoSession[] = {0, 6};

//
// Declare the expert
//
#define  CExpert  CExpertBase
CExpert     *Expert;

//
// Signals
//
CSignalGrid *EntrySignal;
CSignalGrid *ExitSignal;

//
// TPSL - use child class names instead of CTPSLBase
//
GridTPSL   *TPObject;
GridTPSL   *SLObject;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

//
// Instantiate the expert, use the child class name
//
   Expert   =  new CExpert();

//
// Assign the default values to the expert
//
   Expert.SetVolume(InpVolume);
   Expert.SetTradeComment(InpComment);
   Expert.SetMagic(InpMagicNumber);
   Expert.SetDefaultLotSize(InpDefaultLotSize);
   Expert.SetGridGap(InpGridGap);
   Expert.SetGridNumber(10);
   Expert.SetMaxLotSize(InpMaxLotSize);
   Expert.SetMaxRiskPerTrade(InpMaxRiskPerTrade);
   Expert.SetMinLotSize(InpMinLotSize);
   Expert.SetRiskBase(InpRiskBase);
   Expert.SetRiskDefaultSize(InpRiskDefaultSize);
   Expert.SetUseTradingSession(InpTradingSession);
   Expert.SetSlippage(InpSlippage);

//
// Set up the signals
//
   //EntrySignal =  new CSignalGrid();
   //EntrySignal.SetMaxRiskPerTrade(InpMaxRiskPerTrade);
   //EntrySignal.setMmagic(InpMagicNumber);
//EntrySignal.AddIndicator(Indicator1, 0);

   //ExitSignal  =  new CSignalGrid();
   //ExitSignal.SetMaxRiskPerTrade(InpMaxRiskPerTrade);
   //ExitSignal.setMmagic(InpMagicNumber);
//ExitSignal.AddIndicator(Indicator1, 0);

//
// Add the signals to the expert
//
   //Expert.AddEntrySignal(EntrySignal);
   //Expert.AddExitSignal(ExitSignal);

//
// If using fixed tp and sl set them here in points
//
   Expert.SetTakeProfitValue(0);
   Expert.SetStopLossValue(0);

//
// Set up the Take Profit and Stop Loss objects
// Remember to create child class names, not base
//
   TPObject       =  new GridTPSL();  // Create the object
//IndicatorTPSL1  =  new CIndicatorBase();   // Create an indicator for the tp object
//TPObject.AddIndicator(IndicatorTPSL1, 0);  // Add the indicator to tp
// Set any other properties needed

// And for the SL object
   SLObject       =  new GridTPSL();
//IndicatorTPSL2  =  new CIndicatorBase();
//SLObject.AddIndicator(IndicatorTPSL2, 0);

   Expert.SetTakeProfitObj(TPObject);
   Expert.SetStopLossObj(SLObject);

//
// Finish expert initialisation and check result
//
   int   result   =  Expert.OnInit();

   return(result);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   EventKillTimer();

   delete   Expert;
   delete   ExitSignal;
   delete   EntrySignal;
   delete   TPObject;
   delete   SLObject;

   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   Expert.OnTick();
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   Expert.OnTimer();
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTrade()
  {

   Expert.OnTrade();
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {

   Expert.OnTradeTransaction(trans, request, result);
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {

   return(Expert.OnTester());

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTesterInit()
  {

   Expert.OnTesterInit();
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTesterPass()
  {

   Expert.OnTesterPass();
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {

   Expert.OnTesterDeinit();
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   Expert.OnChartEvent(id, lparam, dparam, sparam);
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {

   Expert.OnBookEvent();
   return;

  }

//+------------------------------------------------------------------+
