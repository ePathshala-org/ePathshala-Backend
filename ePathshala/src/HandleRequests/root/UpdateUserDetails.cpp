#include "UpdateUserDetails.h"

void UpdateUserDetails(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Update \"user-details\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("SELECT UPDATE_USER_DETAILS($1, $2, $3, $4, $5, $6) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["full_name"].asString(), request["email"].asString(), request["password"].asString(), request["bio"].asString(), request["date_of_birth"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["return"] = result[0]["RETURN"].as<Json::Int>();

    response["ok"] = true;
}