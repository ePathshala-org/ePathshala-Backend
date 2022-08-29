#include "Page.h"

void InsertPage(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Insert \"page\" request" << std::endl;

    std::stringstream queryStream("SELECT INSERT_CONTENT($1, $2, $3, $4) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), Json::String("PAGE"), request["course_id"].asInt64(), request["title"].asString(), Json::String(""));

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();
    std::string docRoot = httpAppFramework.getDocumentRoot();
    std::string parent = docRoot + "/contents/pages/" + request["course_id"].asString();

    if(!std::filesystem::exists(parent))
    {
        std::filesystem::create_directories(parent);
    }

    std::string path = parent + "/" + result[0]["RETURN"].as<Json::String>() + ".json";
    std::ofstream fileStream(path);

    fileStream << request["content"];

    fileStream.close();

    response["ok"] = true;
}