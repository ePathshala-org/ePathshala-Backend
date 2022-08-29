#include "GetPageContent.h"

void GetPageContent(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Get \"page-content\" request" << std::endl;

    std::string docRoot = httpAppFramework.getDocumentRoot();
    std::string path = docRoot + "/contents/pages/" + request["course_id"].asString() + "/" + request["content_id"].asString() + ".json";
    std::ifstream fileStream(path);

    fileStream >> response["content"];

    response["ok"] = true;
}