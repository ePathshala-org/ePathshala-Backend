#include "Login.h"

void Login(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Login request" << std::endl;

    std::stringstream queryStream("SELECT LOGIN($1, $2, $3) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["email"].asString(), request["password"].asString(), request["student"].asBool());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["return"] = result[0]["RETURN"].as<Json::Int64>();
    response["ok"] = true;
}