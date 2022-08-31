#include "Question.h"

void DeleteQuestion(Json::Value &request, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Delete \"question\" reqeust" << std::endl;

    std::stringstream queryStream("CALL DELETE_QUESTION($1)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["question_id"].asInt64());

    std::string docRoot = httpAppFramework.getDocumentRoot();
    std::string path = docRoot + "/questions/" + request["question_id"].asString() + ".json";

    remove(path.c_str());
}