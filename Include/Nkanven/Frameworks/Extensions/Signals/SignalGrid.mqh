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
   double               lastBuyOrderPrice;
   double               lastSellOrderPrice;
   double               openedBuyPositionPrice;
   double               openedSellPositionPrice;

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

   virtual double                      getLastBuyOrderPrice() {return lastBuyOrderPrice;}
   virtual double                      getLastSellOrderPrice() {return lastSellOrderPrice;}
   virtual double                      getOpenedBuyPositionPrice() {return openedBuyPositionPrice;}
   virtual double                      getOpenedSellPositionPrice() {return openedSellPositionPrice;}
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

// Check the account balance equity for profit
   int pCountBuy = 0, pCountSell = 0, oCountBuy = 0, oCountSell = 0, totalBuy = 0, totalSell = 0, realTotalBuy = 0, realTotalSell = 0;
   int realOCountBuy, realOCountSell;
   ulong ticket;

   SetSignal(OFX_ENTRY_SIGNAL, OFX_SIGNAL_NONE);

//If there're many positions and account balance is negative

   Print("There is ", PositionsTotal(), " opened positions");
   if(PositionsTotal() > 0)
     {
      //Count the opened positions by type
      int   cntP      =  PositionsTotal();
      for(int i = cntP-1; i>=0; i--)
        {
         ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
           {
            if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY
               && PositionGetInteger(POSITION_MAGIC)==m_magic)
              {
               openedBuyPositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               pCountBuy += 1;
              }

            Print("POSITION_SYMBOL ", PositionGetString(POSITION_SYMBOL), " = ", mSymbol, " POSITION_TYPE ",PositionGetInteger(POSITION_TYPE), " = ", POSITION_TYPE_SELL, " Magic ", PositionGetInteger(POSITION_MAGIC), " = ",m_magic);
            if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL
               && PositionGetInteger(POSITION_MAGIC)==m_magic)
              {
               openedSellPositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               pCountSell += 1;
              }
           }
         else
           {
            Print(GetLastError());
           }
        }
     }
//Count the orders by type

   int   cntO      =  OrdersTotal();
   Print("Total pending orders ", cntO);
   for(int i = cntO-1; i>=0; i--)
     {
      ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetString(ORDER_SYMBOL)==mSymbol && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_STOP
            && OrderGetInteger(ORDER_MAGIC)==m_magic)
           {
            oCountBuy += 1;
            lastBuyOrderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
           }

         Print("ORDER_SYMBOL ", OrderGetString(ORDER_SYMBOL), " Real symbol ", mSymbol, " ORDER_TYPE ", OrderGetInteger(ORDER_TYPE), " Real type ", ORDER_TYPE_SELL_STOP, " Magic ", OrderGetInteger(ORDER_MAGIC), " Real magic ", m_magic);
         if(OrderGetString(ORDER_SYMBOL)==mSymbol && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_STOP
            && OrderGetInteger(ORDER_MAGIC)==m_magic)
           {
            oCountSell += 1;
            lastSellOrderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
           }
        }
      else
        {
         Print(GetLastError());
        }
     }
   Print("openedBuyPositionPrice ", openedBuyPositionPrice, " openedSellPositionPrice ", openedSellPositionPrice);

   Print("lastBuyOrderPrice ", lastBuyOrderPrice, " lastSellOrderPrice ", lastSellOrderPrice);

   double floatingProfitPercent = ((AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE))*100)/AccountInfoDouble(ACCOUNT_BALANCE);
// Check if profit is at least the mMaxRiskPerTrade

   Print(" MaxRiskPerTrade ",mMaxRiskPerTrade, " Floating profit percent ", floatingProfitPercent, " Account equity ", AccountInfoDouble(ACCOUNT_EQUITY), " Account balance ", AccountInfoDouble(ACCOUNT_BALANCE));

//The number of buy pending order should be twice the opened sell positions; and vice versa
   realOCountBuy = pCountSell+1;
   realOCountSell = pCountBuy*2;
   totalBuy = pCountBuy+oCountBuy;
   totalSell = pCountSell+oCountSell;
   realTotalBuy = pCountSell+1;
   realTotalSell = pCountBuy+1;
   
   Print("Sell order (", oCountSell, ") Real (", realOCountSell, ")");
   Print("Buy order (", oCountBuy, ") Real (", realOCountBuy, ")", " Opened sell ", pCountSell);


   Print("oCountSell ", oCountSell, " < ", " realOCountSell ", realOCountSell, " && ", " pCountBuy ", pCountBuy," > 0");

   if(OrdersTotal() == 0 && PositionsTotal() == 0)
     {
     SetSignal(OFX_ENTRY_SIGNAL, OFX_SIGNAL_BOTH);
     }
   else
     {
      //If there's only one pending order left, close it.
      if(OrdersTotal() >= 1 && PositionsTotal() == 0)
        {
        SetSignal(OFX_EXIT_SIGNAL, OFX_SIGNAL_ALL);
         Print("Exit if no opened position");
        }
      else
        {
         //When there are multiple positions, check is the account is making enough profit
         if(floatingProfitPercent > mMaxRiskPerTrade)
           {
           SetSignal(OFX_EXIT_SIGNAL, OFX_SIGNAL_ALL);
            Print("Exit on profit target");
           }
         else
           {
           Print("realTotalSell ", realTotalSell, " <= ", " totalSell ", totalSell ," && ", " pCountBuy ",pCountBuy ," > 0");
            if(realTotalSell > totalSell && pCountBuy > 0)
              {
              SetSignal(OFX_ENTRY_SIGNAL, OFX_SIGNAL_SELL);
               Print("Sell order (", oCountSell, ") is less than it should be (", realOCountSell, ")");
              }
            else
              {
               if(realTotalBuy > totalBuy && pCountSell > 0)
                 {
                 SetSignal(OFX_ENTRY_SIGNAL, OFX_SIGNAL_BUY);
                  //mEntrySignals[0].SetSignal(OFX_ENTRY_SIGNAL, OFX_SIGNAL_BUY);
                  Print("Buy order (", oCountBuy, ") is less than it should be (", realOCountBuy, ")");
                 }
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
