#include "GetComments.h"

void GetInterests(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"interests\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("SELECT GET_INTERESTS($1) AS INTEREST");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["ok"] = true;

    for(size_t i = 0; i < result.size(); ++i)
    {
        response["interests"].append(result[i]["INTEREST"].as<Json::String>());
    }
}