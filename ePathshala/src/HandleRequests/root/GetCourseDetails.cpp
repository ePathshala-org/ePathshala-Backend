#include "GetCourseDetails.h"

void GetCourseDetails(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"course-details\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-course-details.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["course_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["course_id"] = result[0]["COURSE_ID"].as<Json::Int64>();
    response["title"] = result[0]["TITLE"].as<Json::String>();
    response["description"] = result[0]["DESCRIPTION"].as<Json::String>();
    response["date_of_creation"] = result[0]["DATE_OF_CREATION"].as<Json::String>();
    response["price"] = result[0]["PRICE"].as<Json::Int>();
    response["rate"] = result[0]["RATE"].as<double>();
    response["enroll_count"] = result[0]["ENROLL_COUNT"].as<Json::Int64>();
    response["creator_id"] = result[0]["CREATOR_ID"].as<Json::Int64>();
    response["creator_name"] = result[0]["CREATOR_NAME"].as<Json::String>();
    response["ok"] = true;
}