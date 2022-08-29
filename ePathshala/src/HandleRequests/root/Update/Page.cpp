#include "Page.h"

void UpdatePage(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Update \"page\" request" << std::endl;

    std::stringstream queryStream("SELECT UPDATE_PAGE($1, $2) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["content_id"].asInt64(), request["title"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result[0]["RETURN"].as<Json::Int>() == 0)
    {
        std::string docRoot = httpAppFramework.getDocumentRoot();
        std::string path = docRoot + "/contents/pages/" + request["course_id"].asString() + "/" + request["content_id"].asString() + ".json";
        std::ofstream fileStream(path);

        fileStream << request["content"];

        fileStream.close();
    }

    response["return"] = result[0]["RETURN"].as<Json::Int>();
    response["ok"] = true;
}