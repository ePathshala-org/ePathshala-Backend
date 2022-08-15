#include "GetTeacherDetails.h"

void GetTeacherDetails(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"teacher-details\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("SELECT * FROM GET_TEACHER_DETAILS($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["teacher_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < request["select"].size(); ++i)
    {
        Json::String defaultValue = "null";
        std::string column = request["select"].get(i, defaultValue).asString();
        response[column] = result[0][column].as<Json::String>();
    }
    
    response["ok"] = true;
}