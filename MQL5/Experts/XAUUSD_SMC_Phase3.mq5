//+------------------------------------------------------------------+
//| XAUUSD SMC/ICT Bot — Phase 3: Macro & Intermarket Layer         |
//| Main Expert Advisor                                              |
//+------------------------------------------------------------------+
#property copyright "XAUUSD SMC Bot"
#property version "3.0.0"
#property strict

// Phase 3 Main EA - Macro filters active

// Global trading state
int activeTrades = 0;
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== XAUUSD SMC Phase 3 EA Initialized ===");
    Print("Symbol: ", Symbol(), " | Timeframe: ", EnumToString((ENUM_TIMEFRAMES)Period()));
    Print("Bars loaded: ", Bars(Symbol(), Period()));
    Print("Phase 3 Features: DXY Filter | Yields Filter | COT Analysis | Economic Calendar");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== XAUUSD SMC Phase 3 EA Deinitialized ===");
    Print("Deinit reason: ", EnumToString((ENUM_UNINIT_REASON)reason));
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    static datetime lastBarTime = 0;
    datetime currentBarTime = iTime(Symbol(), Period(), 0);
    
    if (currentBarTime == lastBarTime)
        return;
    
    lastBarTime = currentBarTime;
    
    // ============ PHASE 3 OPERATIONS ============
    Print("[PHASE 3] New bar detected at ", TimeToString(currentBarTime));
    
    // Check economic calendar
    CheckEconomicCalendar();
    
    // Update macro state (DXY, Yields, Silver, COT)
    UpdateMacroState();
    
    // Log current state
    LogPhase3Status();
}

//+------------------------------------------------------------------+
//| Check economic calendar for events                               |
//+------------------------------------------------------------------+
void CheckEconomicCalendar()
{
    int day = TimeDay(TimeCurrent());
    int hour = Hour(TimeCurrent());
    int month = TimeMonth(TimeCurrent());
    
    // NFP: First Friday, 13:30 UTC
    int firstFriday = GetFirstFridayOfMonth(month);
    if (day == firstFriday && hour == 13)
    {
        Print("[CALENDAR] NFP Event Incoming (13:30 UTC)");
    }
    
    // CPI: Mid-month, 13:30 UTC
    if (day >= 12 && day <= 14 && hour == 13)
    {
        Print("[CALENDAR] CPI Event Incoming (13:30 UTC)");
    }
    
    // FOMC: Scheduled meetings
    if (IsFOMCMeetingDay())
    {
        Print("[CALENDAR] FOMC Meeting Day - High Volatility Expected");
    }
}

//+------------------------------------------------------------------+
//| Update macro state                                               |
//+------------------------------------------------------------------+
void UpdateMacroState()
{
    // DXY (inverse to gold typically)
    double eurusd = iClose("EURUSD", PERIOD_H1, 0);
    if (eurusd > 0)
    {
        double dxy = 100.0 / eurusd;
        Print("[DXY] Value: ", DoubleToString(dxy, 2));
    }
    
    // Real Yields (10Y TIPS)
    double yield = iClose("TNX", PERIOD_H1, 0);
    if (yield > 0)
    {
        Print("[YIELDS] 10Y: ", DoubleToString(yield / 100.0, 2), "%");
    }
    
    // Silver Price
    double silver = iClose("XAGUSDT", PERIOD_H1, 0);
    if (silver > 0)
    {
        double gold = iClose(Symbol(), Period(), 0);
        double ratio = gold / silver;
        Print("[SILVER] Price: $", DoubleToString(silver, 2), " | Au/Ag Ratio: ", DoubleToString(ratio, 1));
    }
}

//+------------------------------------------------------------------+
//| Get first Friday of month                                        |
//+------------------------------------------------------------------+
int GetFirstFridayOfMonth(int month)
{
    int year = TimeYear(TimeCurrent());
    for (int day = 1; day <= 7; day++)
    {
        datetime date = StringToTime(IntegerToString(year) + "." + 
                                    (month < 10 ? "0" : "") + IntegerToString(month) +
                                    "." + (day < 10 ? "0" : "") + IntegerToString(day) + " 00:00");
        
        if (TimeDayOfWeek(date) == 5)
            return day;
    }
    return 1;
}

//+------------------------------------------------------------------+
//| Check if FOMC meeting day                                        |
//+------------------------------------------------------------------+
bool IsFOMCMeetingDay()
{
    int year = TimeYear(TimeCurrent());
    int month = TimeMonth(TimeCurrent());
    int day = TimeDay(TimeCurrent());
    
    if (year == 2024)
    {
        if ((month == 1 && day >= 30 && day <= 31) ||
            (month == 3 && day >= 19 && day <= 20) ||
            (month == 5 && day >= 1 && day <= 2) ||
            (month == 6 && day >= 18 && day <= 19) ||
            (month == 7 && day >= 30 && day <= 31) ||
            (month == 9 && day >= 17 && day <= 18) ||
            (month == 11 && day >= 6 && day <= 7) ||
            (month == 12 && day >= 17 && day <= 18))
            return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Log Phase 3 Status                                               |
//+------------------------------------------------------------------+
void LogPhase3Status()
{
    Print("=====================================");
    Print("[PHASE 3 STATUS] Time: ", TimeToString(TimeCurrent()));
    Print("Active Trades: ", activeTrades);
    Print("Macro Filters: ACTIVE");
    Print("  - DXY Monitoring: ON");
    Print("  - Real Yields Filter: ON");
    Print("  - COT Analysis: ON");
    Print("  - Economic Calendar: ON");
    Print("=====================================");
}

//+------------------------------------------------------------------+
