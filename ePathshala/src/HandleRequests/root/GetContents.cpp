#include "GetContents.h"

void GetContents(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::ifstream inputFileStream("./sql/get-contents.sql");

    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["course_id"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value course;

        course["content_id"] = result[i]["CONTENT_ID"].as<Json::Int64>();
        course["title"] = result[i]["TITLE"].as<Json::String>();
        course["description"] = result[i]["DESCRIPTION"].as<Json::String>();
        course["rate"] = result[i]["RATE"].as<double>();
        course["date_of_creation"] = result[i]["DATE_OF_CREATION"].as<Json::String>();
        course["content_type"] = result[i]["CONTENT_TYPE"].as<Json::String>();
        course["view_id"] = result[i]["VIEW_COUNT"].as<Json::Int64>();

        response["courses"].append(course);
    }
}