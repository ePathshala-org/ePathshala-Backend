#include "GetUserId.h"

void GetUserId(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"user-id\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-user-id.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["email"].asString(), request["security_key"].asString(), request["student"].asBool());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["USER_ID"] = result[0]["GET_USER_ID"].as<Json::Int64>();
    response["ok"] = true;
}