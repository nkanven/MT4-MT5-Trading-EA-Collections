//+------------------------------------------------------------------+
//|                                                Notifications.mqh |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin.com/in/nkondog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin.com/in/nkondog"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(string message)
  {

   SendNotification(message);

   string  headers;
   string  url = "https://api.telegram.org/bot1203586996:AAF3GTCy2yVyvXsCjd9pODhJncTUG7NcOKw/sendMessage?chat_id=-457969372&text="+message;
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
   //Print(CharArrayToString(result));       // see the results

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
  }
//+------------------------------------------------------------------+
