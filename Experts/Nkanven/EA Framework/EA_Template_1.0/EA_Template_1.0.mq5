//+------------------------------------------------------------------+
//|                                              EA_Template_1.0.mq5 |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <Expert\Expert.mqh>
#include <Expert\ExpertBase.mqh>

//Input section



//Some standard inputs
input double inpVolume             = 0.01;             //Default order size
input string inpComment            = __FILE__;         //Default trade comment
input int    inpMagicNumber        = 12345;            //Magic number


//Declare the Expert
#define CExpert CExpertBase
CExpert *Expert;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  //Assign the default values to the expert
Expert = new CExpert();

Expert.SetVolume(inpVolume);
Expert.SetTradeComment(__FILE__);
Expert.SetMagic(inpMagicNumber);


//--- create timer
   EventSetTimer(60);
   
   int result = Expert.OnInit();
   
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   delete Expert;
   return;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Expert.OnTick();
   return;
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   Expert.OnTimer();
   return;
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   Expert.OnTrade();
   return;
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   Expert.OnTradeTransaction(trans, request, result);
   return;
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   //double ret=0.0;
//---

//---
   //return(ret);
   return(Expert.OnTester());
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   Expert.OnTesterInit();
   return;
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   Expert.OnTesterPass();
   return;
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   Expert.OnTesterDeinit();
   return;
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   Expert.OnChartEvent(id, lparam, dparam, sparam);
   return;
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   Expert.OnBookEvent();
   return;
  }
//+------------------------------------------------------------------+
