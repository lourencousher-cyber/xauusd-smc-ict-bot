//+------------------------------------------------------------------+
//| Macro Analyzer Module — DXY, Real Yields, Silver Tracking        |
//+------------------------------------------------------------------+
#ifndef MACRO_ANALYZER_MQH
#define MACRO_ANALYZER_MQH

struct SMacroState
{
    double dxyValue;
    double dxyChange;
    double realYieldsValue;
    double silverValue;
    double goldSilverRatio;
    bool ratioExtreme;
    double cotLongPercent;
    datetime lastUpdate;
    bool dataValid;
};

class CMacroAnalyzer
{
private:
    SMacroState macroState;
    double lastDXY;
    double lastYields;
    double lastSilver;
    datetime lastUpdateTime;
    
public:
    CMacroAnalyzer() 
    {
        lastDXY = 0;
        lastYields = 0;
        lastSilver = 0;
        lastUpdateTime = 0;
        macroState.dataValid = false;
    }
    
    bool Init()
    {
        Print("[MacroAnalyzer] Initialized");
        return true;
    }
    
    SMacroState UpdateMacroState()
    {
        datetime currentTime = TimeCurrent();
        
        if (currentTime - lastUpdateTime < 3600)
            return macroState;
        
        lastUpdateTime = currentTime;
        
        // Update DXY (via EURUSD inverse)
        double eurusd = iClose("EURUSD", PERIOD_H1, 0);
        if (eurusd > 0)
        {
            macroState.dxyValue = 100.0 / eurusd;
            if (lastDXY > 0)
                macroState.dxyChange = ((macroState.dxyValue - lastDXY) / lastDXY) * 100.0;
            lastDXY = macroState.dxyValue;
        }
        
        // Update Yields
        macroState.realYieldsValue = iClose("TNX", PERIOD_H1, 0) / 100.0;
        if (macroState.realYieldsValue <= 0)
            macroState.realYieldsValue = 1.5;
        
        // Update Silver
        double silverPrice = iClose("XAGUSDT", PERIOD_H1, 0);
        if (silverPrice > 0)
            macroState.silverValue = silverPrice;
        else
            macroState.silverValue = 0;
        
        // Au/Ag Ratio
        double goldPrice = iClose(Symbol(), Period(), 0);
        if (macroState.silverValue > 0 && goldPrice > 0)
        {
            macroState.goldSilverRatio = goldPrice / macroState.silverValue;
            macroState.ratioExtreme = (macroState.goldSilverRatio > 90.0 || 
                                       macroState.goldSilverRatio < 60.0);
        }
        
        macroState.lastUpdate = currentTime;
        macroState.dataValid = true;
        
        return macroState;
    }
    
    SMacroState GetMacroState()
    {
        return macroState;
    }
    
    void LogMacroAnalysis()
    {
        Print("[MACRO] DXY=", DoubleToString(macroState.dxyValue, 2),
              " | Yields=", DoubleToString(macroState.realYieldsValue, 2),
              "% | Au/Ag=", DoubleToString(macroState.goldSilverRatio, 1));
    }
};

#endif
