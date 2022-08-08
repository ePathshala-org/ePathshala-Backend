#include "GetTeacherDetailsHome.h"

void GetTeacherDetailsHome(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"teacher-details-home\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-teacher-details-home.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["user_id"].as<Json::Int64>());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result.size())
    {
        std::clog << "Making response" << std::endl;

        response["ok"] = true;
        response["full_name"] = result[0]["FULL_NAME"].as<Json::String>();
        response["email"] = result[0]["EMAIL"].as<Json::String>();
        response["bio"] = result[0]["BIO"].as<Json::String>();
        response["rate"] = result[0]["RATE"].as<Json::String>();
    }
    else
    {
        std::clog << "No such user id, could not make response" << std::endl;

        response["ok"] = false;
    }

    inputFileStream.close();
}