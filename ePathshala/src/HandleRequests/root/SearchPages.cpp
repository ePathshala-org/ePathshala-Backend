#include "SearchVideos.h"

void SearchPages(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Search \"pages\" request" << std::endl;

    std::stringstream queryStream("SELECT * FROM SEARCH_PAGES($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["term"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value page;

        page["CONTENT_ID"] = result[i]["CONTENT_ID"].as<Json::Int64>();
        page["TITLE"] = result[i]["TITLE"].as<Json::String>();
        page["COURSE_ID"] = result[i]["COURSE_ID"].as<Json::Int64>();
        response["pages"].append(page);
    }

    response["ok"] = true;
}