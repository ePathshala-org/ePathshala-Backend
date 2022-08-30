#include "CollectCredit.h"

void CollectCredit(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Collect credit request" << std::endl;

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

    std::stringstream queryStream("SELECT * FROM GET_TEACHER_DETAILS($1)");

    std::shared_future<drogon::orm::Result> resultTeacherDetailsFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64());

    resultTeacherDetailsFuture.wait();

    drogon::orm::Result resultTeacherDetails = resultTeacherDetailsFuture.get();

    drogon::HttpClientPtr httpClientPtr = drogon::HttpClient::newHttpClient(url, port);
    Json::Value addRequest;

    addRequest["type"] = Json::String("add");
    addRequest["client_id"] = request["credit_card_id"].asInt64();
    addRequest["password"] = request["password"].asString();
    addRequest["amount"] = resultTeacherDetails[0]["CREDIT"].as<Json::Int>();

    drogon::HttpRequestPtr httpSubtractRequestPtr = drogon::HttpRequest::newHttpJsonRequest(addRequest);

    httpSubtractRequestPtr->setPath("/");
    httpSubtractRequestPtr->setMethod(drogon::Post);

    std::pair<drogon::ReqResult, drogon::HttpResponsePtr> responsePair = httpClientPtr->sendRequest(httpSubtractRequestPtr);

    if(responsePair.first == drogon::ReqResult::Ok)
    {
        Json::Value &addResponse = *responsePair.second->getJsonObject().get();

        if(addResponse["return"].asInt() == 0)
        {
            queryStream.str("CALL COLLECT_TEACHER_CREDIT($1)");

            dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64());
        }

        response["return"] = addResponse["return"].asInt();
        response["ok"] = true;
    }
}
