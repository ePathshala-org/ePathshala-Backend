#include "GetCourseContents.h"

void GetCourseContents(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"course-contents\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-contents.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["course_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value content;

        content["content_id"] = result[i]["CONTENT_ID"].as<Json::Int64>();
        content["title"] = result[i]["TITLE"].as<Json::String>();
        content["description"] = result[i]["DESCRIPTION"].as<Json::String>();
        content["rate"] = result[i]["RATE"].as<double>();
        content["date_of_creation"] = result[i]["DATE_OF_CREATION"].as<Json::String>();
        content["content_type"] = result[i]["CONTENT_TYPE"].as<Json::String>();
        content["view_count"] = result[i]["VIEW_COUNT"].as<Json::Int64>();

        response["contents"].append(content);
    }

    response["ok"] = true;
}