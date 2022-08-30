#include "Add.h"

void Add(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "add" << std::endl;

    std::stringstream queryStream;

    queryStream << "SELECT ADD_CREDIT($1, $2, $3)";

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["client_id"].asInt64(), request["password"].asString(), request["amount"].asInt());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["return"] = result[0]["ADD_CREDIT"].as<Json::Int>();
    response["ok"] = true;

    std::clog << "Response made" << std::endl;
}