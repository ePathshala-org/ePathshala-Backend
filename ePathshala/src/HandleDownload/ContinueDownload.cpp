#include "ContinueDownload.h"

void ContinueDownload(Json::Value &request, Json::Value &response, std::vector<std::pair<std::string, std::fstream>> &downloads)
{
    size_t index = request["index"].asUInt();
    
    downloads[index].second << request["content"].asString();
    
    response["next"] = true;
    response["ok"] = true;
}