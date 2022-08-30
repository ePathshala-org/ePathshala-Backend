#include <iostream>
#include <fstream>
#include <algorithm>
#include <drogon/drogon.h>
#include "HandleRequests.h"

int main()
{
	drogon::HttpAppFramework &httpAppFramework = drogon::app().addListener("127.0.0.1", 8081);

    drogon::orm::DbClientPtr dbClientPtr = drogon::orm::DbClient::newPgClient("user=a_bank password=1234 dbname=a_bank", 1);
    drogon::orm::DbClient &dbClient = *dbClientPtr.get();

	httpAppFramework.setThreadNum(16);

	httpAppFramework.registerHandler("/",
    [&dbClient](const drogon::HttpRequestPtr &httpRequestPtr, std::function<void(const drogon::HttpResponsePtr &)> &&callback)
    {
        Json::Value &request = *httpRequestPtr->getJsonObject().get();
        Json::Value response;

        if(request["type"].asString() == "subtract")
        {
            Subtract(request, response, dbClient);
        }
        else if(request["type"].asString() == "add")
        {
            Add(request, response, dbClient);
        }

        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpJsonResponse(response);

        std::clog << "Sending Response" << std::endl;
        
        callback(httpResponsePtr);
    },
    {drogon::Post});

	httpAppFramework.run();

	return 0;
}