//+------------------------------------------------------------------+
//|                                               E_CheckHistory.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckHistory()
  {
   ulong    ticket=0;
   double   profit;
   datetime time;
   string   symbol;
   long     type;
   long     entry;

   datetime timeStart = TimeCurrent() - PeriodSeconds(PERIOD_D1);
   HistorySelect(timeStart,TimeCurrent());
   uint     total=HistoryDealsTotal();
   //lotMultiplier = 1;
   Print("Total deal in history ", total);

   for(uint i=0; i<total; i++)
     {
      //--- essaye de récuperer le ticket des transactions
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- récupère les propriétés des transactions
         time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         type  =HistoryDealGetInteger(ticket,DEAL_TYPE);
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         //--- seulement pour le symbole courant

         //Print("Ticket ", ticket," Time ", TimeToString(time, TIME_MINUTES));

         if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL && profit != 0.0)
           {
            lt.time = TimeToString(time, TIME_DATE);
            lt.type = IntegerToString(type);
            lt.profit = profit;
            Print("--- Today history --> Ticket ", ticket, " heure ", TimeToString(time, TIME_DATE), " Symbol ", symbol, " type ", type, " entree ", entry, " profit ", profit);
           }
        }
     }
  }
//+------------------------------------------------------------------+
