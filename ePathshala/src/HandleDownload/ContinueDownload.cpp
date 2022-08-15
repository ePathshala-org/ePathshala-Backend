#include "ContinueDownload.h"

void ContinueDownload(Json::Value &request, Json::Value &response, std::vector<std::pair<std::string, std::fstream>> &downloads)
{
    std::clog << "continue-download" << std::endl;

    size_t index = request["index"].asUInt();
    
    for(size_t i = 0; i < request["content"].size(); ++i)
    {
        //downloads[index].second << (uint8_t)request["content"].get(i, uint8_t(0)).asInt();
        uint8_t writeData = (uint8_t)request["content"].get(i, uint8_t(0)).asInt();

        downloads[index].second.write((char *)&writeData, 1);
    }
    
    response["next"] = true;
    response["ok"] = true;
}