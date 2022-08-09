#include "GetContentDetails.h"

void GetContentDetails(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"content-course-details\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-content-details.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["content_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result.size() > 0)
    {
        response["content_id"] = result[0]["CONTENT_ID"].as<Json::Int64>();
        response["date_of_creation"] = result[0]["DATE_OF_CREATION"].as<Json::String>();
        response["content_type"] = result[0]["CONTENT_TYPE"].as<Json::String>();
        response["rate"] = result[0]["RATE"].as<double>();
        response["title"] = result[0]["TITLE"].as<Json::String>();
        response["description"] = result[0]["DESCRIPTION"].as<Json::String>();
        response["course_id"] = result[0]["COURSE_ID"].as<Json::Int64>();
        response["viewer_count"] = result[0]["VIEWER_COUNT"].as<Json::Int64>();
        response["ok"] = true;
    }
}