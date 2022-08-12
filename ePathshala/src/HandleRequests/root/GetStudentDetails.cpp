#include "GetStudentDetails.h"

void GetStudentDetails(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"student-details\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-student-details.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asString());

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