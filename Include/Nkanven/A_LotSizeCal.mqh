//+------------------------------------------------------------------+
//|                                                 A_LotSizeCal.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Lot Size Calculator
void LotSizeCalculate(double SL=0)
  {
//If the position size is dynamic
   if(RiskDefaultSize==RISK_DEFAULT_AUTO)
     {
      //If the stop loss is not zero then calculate the lot size
      if(SL!=0)
        {
         double RiskBaseAmount=0;
         //TickValue is the value of the individual price increment for 1 lot of the instrument, expressed in the account currenty
         TickValue=SymbolInfoDouble(Symb,SYMBOL_TRADE_TICK_VALUE);
         //Define the base for the risk calculation depending on the parameter chosen
         if(RiskBase==RISK_BASE_BALANCE)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_BALANCE);
         if(RiskBase==RISK_BASE_EQUITY)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_EQUITY);
         if(RiskBase==RISK_BASE_FREEMARGIN)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_FREEMARGIN);
         //Calculate the Position Size
         Print("Multiplier ", lotMultiplier, "Before lot multiplier ", (RiskBaseAmount*MaxRiskPerTrade/100)/(SL*TickValue));
         Print("RiskBaseAmount ", RiskBaseAmount, " MaxRiskPerTrade ", MaxRiskPerTrade, "Stop loss ", SL, " TickValue ", TickValue);

         LotSize=((RiskBaseAmount*MaxRiskPerTrade/100)/(SL*TickValue));
         
         Print("After lot multiplier ", LotSize, " Lot multiplier ", lotMultiplier);
         if(ActiveMartingale)
           {
            LotSize = LotSize * lotMultiplier;
           }
        }
      //If the stop loss is zero then the lot size is the default one
      if(SL==0)
        {
         LotSize=DefaultLotSize;
        }
     }
//Normalize the Lot Size to satisfy the allowed lot increment and minimum and maximum position size
   LotSize=MathFloor(LotSize/SymbolInfoDouble(Symb,SYMBOL_VOLUME_STEP))*SymbolInfoDouble(Symb,SYMBOL_VOLUME_STEP);

//Limit the lot size in case it is greater than the maximum allowed by the user
   if(LotSize>MaxLotSize)
      LotSize=MaxLotSize;
//Limit the lot size in case it is greater than the maximum allowed by the broker
   if(LotSize>SymbolInfoDouble(Symb,SYMBOL_VOLUME_MAX))
      LotSize=SymbolInfoDouble(Symb,SYMBOL_VOLUME_MAX);
      Print("Lot ", LotSize, " Max lot ", SymbolInfoDouble(Symb,SYMBOL_VOLUME_MAX));
//If the lot size is too small then set it to 0 and don't trade
   if(LotSize < SymbolInfoDouble(Symb,SYMBOL_VOLUME_MIN)) 
   {
      LotSize=0;
      Print("Lot size too small");
   }
  }
