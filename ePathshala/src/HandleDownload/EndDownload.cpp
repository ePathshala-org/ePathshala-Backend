#include "EndDownload.h"

void EndDownload(Json::Value &request, Json::Value &response, std::vector<std::pair<std::string, std::fstream>> &downloads, drogon::HttpAppFramework &httpAppFramework)
{
    size_t index = request["index"].asUInt();

    if(request["task"].asString() == "check-pfp")
    {
        response["return"] = true;

        downloads[index].second.seekg(20);

        size_t width, height;
        
        downloads[index].second.read((char *)&width, 4);
        downloads[index].second.read((char *)&height, 4);

        std::string tempDir = downloads[index].first;
        downloads[index].first = "";

        downloads[index].second.close();

        if(ntohl(width) > 96 || ntohl(height) > 96)
        {
            remove(tempDir.c_str());

            response["return"] = false;
        }
        else
        {
            std::ifstream source(tempDir, std::fstream::binary);
            std::ofstream destination(httpAppFramework.getDocumentRoot() + "/pfp/" + request["data"]["user_id"].asString() + ".png", std::fstream::binary);

            destination << source.rdbuf();

            source.close();
            destination.close();
            remove(tempDir.c_str());

            response["return"] = true;
        }
    }
    else
    {
        downloads[index].first = "";
        downloads[index].second.close();    
    }

    response["ended"] = true;
    response["ok"] = true;
}