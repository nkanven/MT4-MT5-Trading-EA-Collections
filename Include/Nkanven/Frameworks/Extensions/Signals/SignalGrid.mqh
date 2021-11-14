//+------------------------------------------------------------------+
//|                                                   SignalGrid.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
// Next line assumes this file is located in .../Frameworks/Extensions/someFolder
#include "../../GridFramework.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalGrid : public CSignalBase
  {

private:

protected:  // member variables

   // Place any required member variables here
   int                  m_magic;

public:  // constructors

   // Add any required constructor arguments
   // e.g. CSignalXYZ(int periods, double multiplier)
                     CSignalGrid()
      :              CSignalBase()
     {               Init();  }
   // Same constructor with symbol and timeframe added
                     CSignalGrid(string symbol, ENUM_TIMEFRAMES timeframe)
      :              CSignalBase(symbol, timeframe)
     {               Init();  }
                    ~CSignalGrid() {  }

   // Include all arguments to match the constructor
   int               Init();

public:

   // Add this line to override the same function from the parent class
   virtual void                        UpdateSignal();

   virtual void                        setMmagic(int magic) {m_magic = magic;}

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int      CSignalGrid::Init()
  {

// Checks if init has been set to fail by any parent class already
   if(InitResult()!=INIT_SUCCEEDED)
      return(InitResult());

// Assign variables and do any other initialisation here

   return(INIT_SUCCEEDED);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void     CSignalGrid::UpdateSignal()
  {

// Just gather data from the indicators and
//    decide on a trade direction
// This is the trade decision logic
//CSignalBase signal = new CSignalBase();



  }
//+------------------------------------------------------------------+
