#include "Content.h"

void DeleteContent(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Delete \"content\" request" << std::endl;

    std::stringstream queryStream("CALL DELETE_CONTENT($1)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["content_id"].asInt64());
}