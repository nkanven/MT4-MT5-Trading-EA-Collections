/*

   EA_Template.mq5

   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com

	Description: Basic template for framework based MQ4 expert
	Uses: framework_2.02 minimum
	
*/

#property copyright "Copyright 2012-2020, Orchard Forex"
#property link      "https://www.orchardforex.com"
#property version   "1.00"
#property strict

//
//	Load the common code
//
#include "EA_Template.mqh"	//	Remember to change this

void OnTrade() {

	Expert.OnTrade();
	return;

}

void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {

	Expert.OnTradeTransaction(trans, request, result);
	return;

}

void OnBookEvent(const string &symbol) {

	Expert.OnBookEvent();
	return;

}

int OnTesterInit() {

	return(Expert.OnTesterInit());

}

void OnTesterPass() {

	Expert.OnTesterPass();
	return;

}

void OnTesterDeinit() {

	Expert.OnTesterDeinit();
	return;

}
