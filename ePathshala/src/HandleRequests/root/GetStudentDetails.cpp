#include "GetStudentDetails.h"

void GetStudentDetails(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"student-details\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-student-details.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["user_id"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["user_id"] = result[0]["USER_ID"].as<Json::Int64>();
    response["full_name"] = result[0]["FULL_NAME"].as<Json::String>();
    response["security_key"] = result[0]["SECURITY_KEY"].as<Json::String>();
    response["date_of_birth"] = result[0]["DATE_OF_BIRTH"].as<Json::String>();
    response["bio"] = result[0]["BIO"].as<Json::String>();
    response["email"] = result[0]["EMAIL"].as<Json::String>();
    response["address"] = result[0]["ADDRESS"].as<Json::String>();
    response["gender"] = result[0]["GENDER"].as<Json::String>();
    response["credit_card_id"] = result[0]["CREDIT_CARD_ID"].as<Json::Int64>();
    response["bank_id"] = result[0]["BANK_ID"].as<Json::Int64>();
    response["interests"] = result[0]["INTERESTS"].as<Json::String>();
    response["date_of_join"] = result[0]["DATE_OF_JOIN"].as<Json::String>();
    response["rank_point"] = result[0]["RANK_POINT"].as<Json::Int>();
    response["ok"] = true;
}