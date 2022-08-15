#include "StartDownload.h"

void StartDownload(Json::Value &request, Json::Value &response, std::vector<std::pair<std::string, std::fstream>> &downloads, drogon::HttpAppFramework &httpAppFramework)
{
    bool found = false;
    size_t index;

    while(!found)
    {
        for(size_t i = 0; i < downloads.size(); ++i)
        {
            if(!downloads[i].second.is_open())
            {
                found = true;
                downloads[i].first = httpAppFramework.getDocumentRoot() + "/" + request["path"].asString();
                downloads[i].second.open(downloads[i].first, std::fstream::out | std::fstream::binary);
                index = i;

                break;
            }
        }
    }

    response["index"] = Json::UInt(index); // 1 means show me next
    response["ok"] = true;
}