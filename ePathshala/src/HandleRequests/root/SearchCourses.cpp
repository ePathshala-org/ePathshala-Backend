#include "SearchCourses.h"

void SearchCourses(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Search \"courses\" request" << std::endl;

    std::stringstream queryStream("SELECT * FROM SEARCH_COURSES($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["term"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value course;

        course["COURSE_ID"] = result[i]["COURSE_ID"].as<Json::Int64>();
        course["TITLE"] = result[i]["TITLE"].as<Json::Int64>();
        response["courses"].append(course);
    }

    response["ok"] = true;
}