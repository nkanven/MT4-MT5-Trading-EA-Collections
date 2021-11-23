//+------------------------------------------------------------------+
//|                                                   LotSizeCal.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"


//Lot Size Calculator
void LotSizeCalculate(double SL=0)
  {
//If the position size is dynamic
   if(InpRiskDefaultSize==RISK_DEFAULT_AUTO)
     {
      //If the stop loss is not zero then calculate the lot size
      if(SL!=0)
        {
         double RiskBaseAmount=0;
         double RiskBase=0;
         
         //TickValue is the value of the individual price increment for 1 lot of the instrument, expressed in the account currenty
         double TickValue=SymbolInfoDouble(gSymbol,SYMBOL_TRADE_TICK_VALUE);
         //Define the base for the risk calculation depending on the parameter chosen
         if(RiskBase==RISK_BASE_BALANCE)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_BALANCE);
         if(RiskBase==RISK_BASE_EQUITY)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_EQUITY);
         if(RiskBase==RISK_BASE_FREEMARGIN)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_FREEMARGIN);

         //Calculate the Position Size
         LotSize=((RiskBaseAmount*InpMaxRiskPerTrade/100)/(SL*TickValue));
        }
      //If the stop loss is zero then the lot size is the default one
      if(SL==0)
        {
         LotSize=InpDefaultLotSize;
        }
     }
//Normalize the Lot Size to satisfy the allowed lot increment and minimum and maximum position size
   LotSize=MathFloor(LotSize/SymbolInfoDouble(gSymbol,SYMBOL_VOLUME_STEP))*SymbolInfoDouble(gSymbol,SYMBOL_VOLUME_STEP);

//Limit the lot size in case it is greater than the maximum allowed by the user
   if(LotSize>InpMaxLotSize)
      LotSize=InpMaxLotSize;
//Limit the lot size in case it is greater than the maximum allowed by the broker
   if(LotSize>SymbolInfoDouble(gSymbol,SYMBOL_VOLUME_MAX))
      LotSize=SymbolInfoDouble(gSymbol,SYMBOL_VOLUME_MAX);
      Print("Lot ", LotSize, " Max lot ", SymbolInfoDouble(gSymbol,SYMBOL_VOLUME_MAX));
//If the lot size is too small then set it to 0 and don't trade
   if(LotSize<InpMinLotSize || LotSize < SymbolInfoDouble(gSymbol,SYMBOL_VOLUME_MIN)) 
   {
      LotSize=0;
      Print("Lot size too small : ", LotSize);
   }
  }
