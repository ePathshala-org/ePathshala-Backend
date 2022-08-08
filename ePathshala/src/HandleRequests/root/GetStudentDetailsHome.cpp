#include "GetStudentDetailsHome.h"

void GetStudentDetailsHome(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"student-details-home\" request" << std::endl;

            std::ifstream inputFileStream("./sql/get-student-details-home.sql");
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
                response["rank_point"] = result[0]["RANK_POINT"].as<Json::Int>();
            }
            else
            {
                std::clog << "No such user id, could not make response" << std::endl;

                response["ok"] = false;
            }

            inputFileStream.close();
}