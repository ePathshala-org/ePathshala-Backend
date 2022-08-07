#include "Login.h"

void Login(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    if(requestJson["account_type"].as<Json::String>() == "student")
    {
        std::clog << "Got \"login student\" request" << std::endl;

        std::ifstream inputFileStream("../../../sql/login/student/check-email.sql");
        std::stringstream queryStream;

        queryStream << inputFileStream.rdbuf();

        std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString());

        resultFuture.wait();

        drogon::orm::Result result = resultFuture.get();

        if(result.size() > 0)
        {
            std::clog << "Email found" << std::endl;

            response["email_found"] = true;
        }
        else
        {
            std::clog << "Login not accepted" << std::endl;

            response["email_found"] = false;
        }

        if(response["email_found"].as<bool>())
        {
            queryStream.str("");
            inputFileStream.close();
            inputFileStream.open("../../../sql/login/student/email-found.sql");

            queryStream << inputFileStream.rdbuf();

            resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString(), requestJson["password"].asString());

            resultFuture.wait();

            result = resultFuture.get();

            if(result.size() > 0)
            {
                std::clog << "Password matched" << std::endl;

                response["password_matched"] = true;
            }
            else
            {
                response["password_matched"] = false;
            }
        }

        if(response["password_matched"].as<bool>())
        {
            response["user_id"] = result[0]["USER_ID"].as<Json::Int64>();
            response["password"] = result[0]["SECURITY_KEY"].as<Json::String>();
            response["account_type"] = "student";
        }

        inputFileStream.close();
    }
    else
    {
        std::clog << "Got \"login teacher\" request" << std::endl;

        std::ifstream inputFileStream("../../../sql/login/teacher/check-email.sql");
        std::stringstream queryStream;

        queryStream << inputFileStream.rdbuf();

        std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString());

        resultFuture.wait();

        drogon::orm::Result result = resultFuture.get();

        if(result.size() > 0)
        {
            std::clog << "Email found" << std::endl;

            response["email_found"] = true;
        }
        else
        {
            std::clog << "Login not accepted" << std::endl;

            response["email_found"] = false;
        }

        if(response["email_found"].as<bool>())
        {
            queryStream.str("");
            inputFileStream.close();
            inputFileStream.open("../../../sql/login/teacher/email-found.sql");

            queryStream << inputFileStream.rdbuf();

            resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString(), requestJson["password"].asString());

            resultFuture.wait();

            result = resultFuture.get();

            if(result.size() > 0)
            {
                std::clog << "Password matched" << std::endl;

                response["password_matched"] = true;
            }
            else
            {
                response["password_matched"] = false;
            }
        }

        if(response["password_matched"].as<bool>())
        {
            response["user_id"] = result[0]["USER_ID"].as<Json::Int64>();
            response["password"] = result[0]["SECURITY_KEY"].as<Json::String>();
            response["account_type"] = "teacher";
        }

        inputFileStream.close();
    }
    
    response["ok"] = true;
}