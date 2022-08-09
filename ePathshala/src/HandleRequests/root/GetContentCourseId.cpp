#include "GetContentCourseId.h"

void GetContentCourseId(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"content-course-id\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-content-details.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["content_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result.size() > 0)
    {
        response["course_id"] = result[0]["COURSE_ID"].as<Json::Int64>();
        response["ok"] = true;
    }
}