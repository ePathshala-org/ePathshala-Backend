#include "GetUserDetails.h"

void GetUserDetails(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"user-details\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-user-details.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result.size() > 0)
    {
        for(size_t i = 0; i < request["select"].size(); ++i)
        {
            Json::String defaultValue = "null";
            std::string column = request["select"].get(i, defaultValue).asString();
            response[column] = result[0][column].as<Json::String>();
        }

        response["ok"] = true;
    }
}