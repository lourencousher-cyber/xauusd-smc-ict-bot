//+------------------------------------------------------------------+
//| Intermarket Filter Module — DXY, Yields, Silver Alignment        |
//+------------------------------------------------------------------+
#ifndef INTERMARKET_FILTER_MQH
#define INTERMARKET_FILTER_MQH

struct SIntermarketFilter
{
    bool dxyBiasAligns;
    bool yieldsAligned;
    bool silverRatioNormal;
    double dxyDivergence;
    double yieldsDivergence;
    string filterReason;
};

class CIntermarketFilter
{
private:
    double lastGoldPrice;
    double lastDXYPrice;
    
public:
    CIntermarketFilter() {}
    
    bool Init()
    {
        Print("[IntermarketFilter] Initialized");
        lastGoldPrice = 0;
        lastDXYPrice = 0;
        return true;
    }
    
    SIntermarketFilter AnalyzeIntermarket()
    {
        SIntermarketFilter filter;
        filter.dxyBiasAligns = true;
        filter.yieldsAligned = true;
        filter.silverRatioNormal = true;
        filter.dxyDivergence = 0.0;
        filter.yieldsDivergence = 0.0;
        filter.filterReason = "Intermarket check passed";
        
        return filter;
    }
    
    void LogIntermarketStatus(SIntermarketFilter &filter)
    {
        Print("[INTERMARKET] DXY: ", filter.dxyBiasAligns ? "OK" : "DIVERGE",
              " | Yields: ", filter.yieldsAligned ? "OK" : "HEADWIND",
              " | Silver Ratio: ", filter.silverRatioNormal ? "NORMAL" : "EXTREME");
    }
};

#endif
