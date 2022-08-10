#include "GetCoursesPopular.h"

void GetCoursesPopular(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"courses-popular\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-courses-popular.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value course;
        course["course_id"] = result[0]["COURSE_ID"].as<Json::Int64>();
        course["title"] = result[0]["TITLE"].as<Json::String>();
        course["description"] = result[0]["DESCRIPTION"].as<Json::String>();
        course["date_of_creation"] = result[0]["DATE_OF_CREATION"].as<Json::String>();
        course["price"] = result[0]["PRICE"].as<Json::Int>();
        course["creator_id"] = result[0]["CREATOR_ID"].as<Json::Int64>();
        course["creator_name"] = result[0]["CREATOR_NAME"].as<Json::String>();
        course["enroll_count"] = result[0]["ENROLL_COUNT"].as<Json::Int64>();

        response["courses"].append(course);
    }

    response["ok"] = true;
}