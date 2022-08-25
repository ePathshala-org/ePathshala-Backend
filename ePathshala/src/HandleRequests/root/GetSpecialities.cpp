#include "GetSpecialities.h"

void GetSpecialities(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"specialities\" request" << std::endl;

    std::stringstream queryStream("SELECT * FROM GET_SPECIALITIES($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["teacher_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        response["specialities"].append(result[i]["SPECIALITY"].as<Json::String>());
    }

    response["ok"] = true;
}