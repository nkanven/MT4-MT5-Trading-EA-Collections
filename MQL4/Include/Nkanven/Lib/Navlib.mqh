//+------------------------------------------------------------------+
//|                                                       Navlib.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

void Notify(string message)
  {
   Print("Message sent ", message);
   
   if(!IsTesting())
     {
      
//SendNotification(message);

   string  headers;
   string  url = "https://api.telegram.org/bot5854676759:AAEGN1a1HQ-3uiVtv7FxEf7IXKrMATBzkQg/sendMessage?chat_id=-1001821417162&text="+message;
   char    data[],result[];

   int res = WebRequest("GET",
                        url,
                        NULL,
                        NULL,
                        3000,
                        data,
                        0,
                        result,
                        headers
                       );
   Print(CharArrayToString(result), " Res ", res, headers);       // see the results

   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      MessageBox("Add the address '"+url+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      if(res==200)
        {
         //--- Successful download
         Print("Telegran notification sent.");
        }
     }
     } else
         {
          Comment(message);
         }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newCandle()
  {
   static datetime prevTime    = 0;
   datetime        currentTime = iTime(Symbol(), PERIOD_CURRENT, 0);
   if(currentTime != prevTime)
     {
      prevTime = currentTime;

      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
