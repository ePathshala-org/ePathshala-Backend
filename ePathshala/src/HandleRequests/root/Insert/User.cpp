#include "User.h"

void InsertUser(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Insert \"user\" request" << std::endl;

    std::stringstream queryStream("SELECT INSERT_USER($1, $2, $3, $4, $5) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["full_name"].asString(), request["email"].asString(), request["password"].asString(), request["date_of_birth"].asString(), request["student"].asBool());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["return"] = result[0]["RETURN"].as<Json::Int>();
    response["ok"] = true;
}