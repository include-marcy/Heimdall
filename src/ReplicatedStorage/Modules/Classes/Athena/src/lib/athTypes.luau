local athTypes = {};

export type athBenchCreateInfo = {

};

export type athPerformanceRatingDiagnosticInfo = {  
    diagnose : {string}; -- a list of function names to try
    athBench : any; -- an athBench instance
};

export type athPerformanceMedal = "ATH_P_MEDAL_GOLD" | "ATH_P_MEDAL_SILVER" | "ATH_P_MEDAL_BRONZE" | "ATH_P_MEDAL_NONE";

return athTypes;