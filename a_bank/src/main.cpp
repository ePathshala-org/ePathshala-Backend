#include <iostream>
#include <fstream>
#include <algorithm>
#include <drogon/drogon.h>

int main()
{
	drogon::HttpAppFramework &httpAppFramework = drogon::app().addListener("127.0.0.1", 8081);

	httpAppFramework.setThreadNum(16);

	httpAppFramework.registerHandler("/",
    [](const drogon::HttpRequestPtr &req, std::function<void(const drogon::HttpResponsePtr &)> &&callback)
    {
        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpResponse();

        httpResponsePtr->setBody("Hehe");
        
        callback(httpResponsePtr);
    },
    {drogon::Post});

	httpAppFramework.run();

	return 0;
}