/*
   SignalBase.mqh

   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com

*/

#include "CommonBase.mqh"
//#include  "IndicatorBase.mqh"

////  New
////  This is to maintain compatibility and allow sub classes to still
////     use mEntrySignal= or mExitSignal=
////  mEntrySignal and mExitSignal are effectively deprecated now
#define mEntrySignal mSignalValues[OFX_ENTRY_SIGNAL]  // Deprecated
#define mExitSignal  mSignalValues[OFX_EXIT_SIGNAL]   // Deprecated


////  New
enum ENUM_OFX_SIGNAL_TYPE
  {
   OFX_ENTRY_SIGNAL,
   OFX_EXIT_SIGNAL
  };

enum ENUM_OFX_SIGNAL_DIRECTION
  {
   OFX_SIGNAL_NONE            =  0,
   OFX_SIGNAL_BUY             =  1,
   OFX_SIGNAL_SELL            =  2,
   OFX_SIGNAL_BOTH            =  3,
   OFX_SIGNAL_ALL             = 4
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalBase : public CCommonBase
  {

private:

protected:  // member variables

   ////  Replaced
   ENUM_OFX_SIGNAL_DIRECTION  mSignalValues[2];
   double            mMaxRiskPerTrade;
   ////ENUM_OFX_SIGNAL_DIRECTION mEntrySignal;
   ////ENUM_OFX_SIGNAL_DIRECTION mExitSignal;

public:  // constructors

                     CSignalBase()                                            :  CCommonBase()
     {               Init();  }
                     CSignalBase(string symbol, ENUM_TIMEFRAMES timeframe)    :  CCommonBase(symbol, timeframe)
     {               Init();  }
                    ~CSignalBase()                                           {  }

   int               Init();

public:

   virtual void                        UpdateSignal()    {  return;                 }
   ////  Changed - maintain backward compatibility
   virtual ENUM_OFX_SIGNAL_DIRECTION   EntrySignal()     {  return(mSignalValues[OFX_ENTRY_SIGNAL]);  }
   virtual ENUM_OFX_SIGNAL_DIRECTION   ExitSignal()      {  return(mSignalValues[OFX_EXIT_SIGNAL]);   }
   ////  New, and shows my lack of planning
   virtual void                        SetSignal(ENUM_OFX_SIGNAL_TYPE type,
         ENUM_OFX_SIGNAL_DIRECTION value)
     {  mSignalValues[type] = value;  }
   virtual void                        SetMaxRiskPerTrade(double maxRiskPerTrade) { mMaxRiskPerTrade = maxRiskPerTrade;}

   virtual ENUM_OFX_SIGNAL_DIRECTION   GetSignal(ENUM_OFX_SIGNAL_TYPE type)
     {               return(mSignalValues[type]);  }

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int      CSignalBase::Init()
  {

   if(InitResult()!=INIT_SUCCEEDED)
      return(InitResult());

////  Replaced
   ArrayInitialize(mSignalValues, OFX_SIGNAL_NONE);
////mEntrySignal     =  OFX_SIGNAL_NONE;
////mExitSignal         =  OFX_SIGNAL_NONE;

   return(INIT_SUCCEEDED);

  }
