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
        course["COURSE_ID"] = result[i]["COURSE_ID"].as<Json::Int64>();
        course["TITLE"] = result[i]["TITLE"].as<Json::String>();
        course["DESCRIPTION"] = result[i]["DESCRIPTION"].as<Json::String>();
        course["DATE_OF_CREATION"] = result[i]["DATE_OF_CREATION"].as<Json::String>();
        course["PRICE"] = result[i]["PRICE"].as<Json::Int>();
        course["CREATOR_ID"] = result[i]["CREATOR_ID"].as<Json::Int64>();
        course["CREATOR_NAME"] = result[i]["CREATOR_NAME"].as<Json::String>();
        course["ENROLL_COUNT"] = result[i]["ENROLL_COUNT"].as<Json::Int64>();
        course["RATE"] = result[i]["RATE"].as<double>();

        response["courses"].append(course);
    }

    response["ok"] = true;
}