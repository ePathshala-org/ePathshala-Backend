#include "View.h"

void InsertView(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Insert \"view\" request" << std::endl;

    std::stringstream queryStream("SELECT INSERT_VIEW($1, $2) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["content_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["return"] = result[0]["RETURN"].as<Json::Int>();
    response["ok"] = true;
}