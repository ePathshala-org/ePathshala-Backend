#include "SetupInitData.h"

void SetupInitData(Json::Value &initData)
{
    std::ifstream initDataJsonIfstream("../data/initData.json");
    Json::Reader initDataJsonReader;

    initDataJsonReader.parse(initDataJsonIfstream, initData);
    initDataJsonIfstream.close();

    std::cout << "***Check Init Data***" << std::endl;
    std::cout << "user: " << initData["dataBaseLoginData"]["user"].asString() << std::endl;
    std::cout << "dbname: " << initData["dataBaseLoginData"]["dbname"].asString() << std::endl;
    std::cout << "password: " << initData["dataBaseLoginData"]["password"].asString() << std::endl;
    std::cout << "ip: " << initData["ip"].asString() << std::endl;
    std::cout << "port: " << initData["port"].asInt() << std::endl;
    std::cout << "docRoot: " << initData["docRoot"].asString() << std::endl;
    std::cout << "***End Check Init Data***" << std::endl;
}