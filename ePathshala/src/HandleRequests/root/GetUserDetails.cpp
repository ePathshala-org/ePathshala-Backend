#include "GetUserDetails.h"

void GetUserDetails(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"user-details\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-user-details.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["user_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result.size() > 0)
    {
        response["user_id"] = result[0]["USER_ID"].as<Json::Int64>();
        response["full_name"] = result[0]["FULL_NAME"].as<Json::String>();
        response["date_of_birth"] = result[0]["DATE_OF_BIRTH"].as<Json::String>();
        response["bio"] = result[0]["BIO"].as<Json::String>();
        response["email"] = result[0]["ADDRESS"].as<Json::String>();
        response["user_type"] = result[0]["USER_TYPE"].as<Json::String>();
        response["gender"] = result[0]["GENDER"].as<Json::String>();
        response["credit_card_id"] = result[0]["CREDIT_CARD_ID"].as<Json::Int64>();
        response["bank_id"] = result[0]["BANK_ID"].as<Json::Int64>();
        response["ok"] = true;
    }
}