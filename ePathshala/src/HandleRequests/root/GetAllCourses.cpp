#include "GetAllCourses.h"

void GetAllCourses(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"All Courses\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-all-courses.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value course;

        course["course_id"] = result[i]["COURSE_ID"].as<Json::Int64>();
        course["title"] = result[i]["TITLE"].as<Json::Int64>();
        course["description"] = result[i]["DESCRIPTION"].as<Json::String>();
        course["date_of_creation"] = result[i]["DATE_OF_CREATION"].as<Json::String>();
        course["price"] = result[i]["PRICE"].as<Json::Int>();
        course["creator_id"] = result[i]["CREATOR_ID"].as<Json::Int64>();
        course["creator_name"] = result[i]["CREATOR_NAME"].as<Json::String>();

        response["courses"].append(course);
    }

    response["ok"] = true;
}