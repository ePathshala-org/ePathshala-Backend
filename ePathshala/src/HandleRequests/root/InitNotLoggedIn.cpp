#include "InitNotLoggedIn.h"

void InitNotLoggedIn(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Got \"init-not-logged-in\" request" << std::endl;

    std::ifstream inputFileStream("./sql/init-not-logged-in/top-courses.sql");

    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    std::clog << "Prepared top-courses" << std::endl;

    for(long i = 0; i < result.size() && i < 5; ++i)
    {
        Json::Value responseRow;

        responseRow["course_id"] = result[i]["COURSE_ID"].as<Json::Int64>();
        responseRow["title"] = result[i]["TITLE"].as<Json::String>();
        responseRow["description"] = result[i]["DESCRIPTION"].as<Json::String>();
        responseRow["price"] = result[i]["PRICE"].as<Json::Int64>();
        responseRow["rate"] = result[i]["RATE"].as<double>();
        responseRow["number_of_enrolls"] = result[i]["NUMBER_OF_ENROLLS"].as<Json::Int64>();

        response["query_top_courses"].append(responseRow);
    }

    queryStream.str("");
    inputFileStream.close();
    inputFileStream.open("./sql/init-not-logged-in/top-videos.sql");

    queryStream << inputFileStream.rdbuf();

    resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

    resultFuture.wait();

    result = resultFuture.get();

    for(long i = 0; i < result.size() && i < 5; ++i)
    {
        Json::Value responseRow;

        responseRow["content_id"] = result[i]["CONTENT_ID"].as<Json::Int64>();
        responseRow["title"] = result[i]["TITLE"].as<Json::String>();
        responseRow["description"] = result[i]["DESCRIPTION"].as<Json::String>();
        responseRow["number_of_viewers"] = result[i]["NUMBER_OF_VIEWERS"].as<Json::Int64>();

        response["query_top_videos"].append(responseRow);
    }

    response["ok"] = true;

    inputFileStream.close();
}