#include "GetCoursesStudent.h"

void GetCoursesStudent(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"course-student\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("SELECT * FROM GET_STUDENT_COURSES_BY_TITLE_ASC($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value course;

        for(size_t j = 0; j < request["select"].size(); ++j)
        {
            Json::String defaultValue = "null";
            std::string column = request["select"].get(j, defaultValue).asString();
            course[column] = result[i][column].as<Json::String>();
        }

        response["courses"].append(course);
    }

    response["ok"] = true;
}