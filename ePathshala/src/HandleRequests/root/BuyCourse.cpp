#include "BuyCourse.h"

void BuyCourse(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Buy Course Request" << std::endl;

    std::string url = "127.0.0.1";
    int port = 8081;

    if(request["bank"].asInt() == 2)
    {
        port = 8082;
    }
    else if(request["bank"].asInt() == 3)
    {
        port = 8083;
    }

    drogon::HttpClientPtr httpClientPtr = drogon::HttpClient::newHttpClient(url, port);
    Json::Value subtractRequest;

    subtractRequest["type"] = Json::String("subtract");
    subtractRequest["client_id"] = request["credit_card_id"].asInt64();
    subtractRequest["password"] = request["password"].asString();
    subtractRequest["amount"] = request["price"].asInt();

    drogon::HttpRequestPtr httpSubtractRequestPtr = drogon::HttpRequest::newHttpJsonRequest(subtractRequest);

    httpSubtractRequestPtr->setPath("/");
    httpSubtractRequestPtr->setMethod(drogon::Post);

    std::pair<drogon::ReqResult, drogon::HttpResponsePtr> responsePair = httpClientPtr->sendRequest(httpSubtractRequestPtr);

    if(responsePair.first == drogon::ReqResult::Ok)
    {
        Json::Value &subtractResponse = *responsePair.second->getJsonObject().get();

        if(subtractResponse["return"].asInt() == 0)
        {
            std::stringstream queryStream;

            queryStream.str("CALL ENROLL_STUDENT($1, $2)");
            dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["course_id"].asInt64());
            queryStream.str("CALL PAY_COURSE_TEACHER_CREDIT($1, $2)");
            dbClient.execSqlAsyncFuture(queryStream.str(), request["course_id"].asInt64(), request["price"].asInt());

        }

        response["return"] = subtractResponse["return"].asInt();
        response["ok"] = true;
    }
}