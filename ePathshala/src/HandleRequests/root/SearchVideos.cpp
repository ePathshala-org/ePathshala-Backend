#include "SearchVideos.h"

void SearchVideos(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Search \"videos\" request" << std::endl;

    std::stringstream queryStream("SELECT * FROM SEARCH_VIDEOS($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["term"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value video;

        video["CONTENT_ID"] = result[i]["CONTENT_ID"].as<Json::Int64>();
        video["TITLE"] = result[i]["TITLE"].as<Json::String>();
        video["COURSE_ID"] = result[i]["COURSE_ID"].as<Json::Int64>();
        response["videos"].append(video);
    }

    response["ok"] = true;
}