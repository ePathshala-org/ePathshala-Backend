#include "Subtract.h"

void Subtract(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "subtract" << std::endl;

    std::stringstream queryStream;

    queryStream << "SELECT SUBTRACT($1, $2)";

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["client_id"].asInt64(), request["password"].asString(), request["amount"].asInt());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["return"] = result[0]["SUBTRACT"].as<bool>();
    response["ok"] = true;

    std::clog << "Response made" << std::endl;
}