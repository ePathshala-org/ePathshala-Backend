#include "GetUserId.h"

void GetUserId(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"user-id\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("SELECT GET_USER_ID($1::VARCHAR, $2::VARCHAR, $3) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["email"].asString(), request["security_key"].asString(), request["is_student"].asBool());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["RETURN"] = result[0]["RETURN"].as<Json::Int64>();
    response["ok"] = true;
}