#include "CreateNewAccount.h"

void CreateNewAccount(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"create-new-account\" request" << std::endl;

    std::ifstream inputFileStream("../../../sql/create-new-account/check-email-in-users.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    inputFileStream.close();

    int64_t nextUserId;

    if
    (
        result.size() > 0 && 
        (
            requestJson["student"].asBool() && result[0]["USER_TYPE"].as<std::string>() == "STUDENT" ||
            !requestJson["student"].asBool() && result[0]["USER_TYPE"].as<std::string>() == "TEACHER"
        )
    )
    {
        nextUserId = 0;
    }
    else
    {
        std::clog << "Finding appropriate ID for new user" << std::endl;

        inputFileStream.open("../../../sql/create-new-account/get-max-user-id.sql");
        queryStream.str("");

        queryStream << inputFileStream.rdbuf();

        std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

        resultFuture.wait();

        drogon::orm::Result result = resultFuture.get();

        inputFileStream.close();

        if(result.size() == 0)
        {
            nextUserId = 1;
        }
        else
        {
            nextUserId = result[0]["MAX_USER_ID"].as<int64_t>() + 1;
        }
    }

    if(nextUserId > 0)
    {
        std::string gender = "F";

        if(requestJson["male"].asBool())
        {
            gender = "M";
        }

        std::string date = requestJson["date_of_birth"]["date"].asString();
        std::string month = requestJson["date_of_birth"]["month"].asString();
        std::string year = requestJson["date_of_birth"]["year"].asString();
        std::string dateOfBirth = date + "-" + month + "-" + year;

        inputFileStream.open("../../../sql/create-new-account/create-new-account.sql");
        queryStream.str("");

        queryStream << inputFileStream.rdbuf();

        std::string userType = "TEACHER";

        if(requestJson["student"].asBool())
        {
            userType = "STUDENT";
        }

        std::clog << "Creating new user" << std::endl;

        dbClient.execSqlAsyncFuture(queryStream.str(), nextUserId, requestJson["name"].asString(), requestJson["email"].asString(), requestJson["password"].asString(), userType, gender);
        inputFileStream.close();
        queryStream.str("");

        if(userType == "STUDENT")
        {
            std::clog << "Creating new student" << std::endl;

            inputFileStream.open("./sql/create-new-account/create-new-student-account.sql");

            queryStream << inputFileStream.rdbuf();

            dbClient.execSqlAsyncFuture(queryStream.str(), nextUserId);
        }
        else
        {
            std::clog << "Creating new teacher" << std::endl;

            inputFileStream.open("./sql/create-new-account/create-new-teacher-account.sql");

            queryStream << inputFileStream.rdbuf();

            dbClient.execSqlAsyncFuture(queryStream.str(), nextUserId);
        }

        response["email_exists"] = false;
        response["user_id"] = nextUserId;
        response["password"] = requestJson["password"].asString();
        
        if(userType == "STUDENT")
        {
            response["account_type"] = "student";
        }
        else
        {
            response["account_type"] = "teacher";
        }
    }
    else
    {
        response["email_exists"] = true;
    }

    response["ok"] = true;
}