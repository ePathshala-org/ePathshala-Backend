#include "GetCourseDetails.h"

void GetCourseDetails(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::ifstream inputFileStream("./sql/get-course-details.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["course_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["course_id"] = result[0]["COURSE_ID"].as<Json::String>();
    response[""]
}