#include "Course.h"

void InsertCourse(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Insert \"course\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("SELECT INSERT_COURSE($1, $2::VARCHAR, $3::VARCHAR, $4::VARCHAR) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["teacher_id"].asInt64(), request["title"].asString(), request["description"].asString(), request["price"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();
    response["return"] = result[0]["RETURN"].as<Json::Int>();
    response["ok"] = true;
}