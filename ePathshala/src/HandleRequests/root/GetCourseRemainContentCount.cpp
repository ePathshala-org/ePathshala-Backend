#include "GetCourseRemainContentCount.h"

void GetCourseRemainContentCount(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"course-remain-content-count\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-course-remain-content-count.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asString(), request["course_id"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result.size() > 0)
    {
        response["CONTENT_COUNT"] = result[0]["CONTENT_COUNT"].as<Json::Int>();
    }
    else
    {
        response["CONTENT_COUNT"] = Json::Int(0);
    }

    response["ok"] = true;
}