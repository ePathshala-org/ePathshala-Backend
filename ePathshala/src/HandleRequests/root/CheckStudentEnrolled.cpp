#include "CheckStudentEnrolled.h"

void CheckUserEnrolled(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Check \"student-enrolled\" request" << std::endl;

    std::stringstream queryStream;

    queryStream << "SELECT CHECK_STUDENT_ENROLLED($1, $2)";

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["course_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result.size())
    {
        response["ENROLLED"] = result[0]["CHECK_STUDENT_ENROLLED"].as<bool>();
    }
    else
    {
        response["ENROLLED"] = false;
    }

    response["ok"] = true;
}