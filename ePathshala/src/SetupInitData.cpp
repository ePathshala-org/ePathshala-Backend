#include "SetupInitData.h"

void SetupInitData(Json::Value &initData)
{
    std::ifstream initDataJsonIfstream("../data/initData.json");

    Json::Reader initDataJsonReader;

    initDataJsonReader.parse(initDataJsonIfstream, initData);
    
    if(!initDataJsonReader.good())
    {
        std::cerr << initDataJsonReader.getFormattedErrorMessages() << std::endl;
    }

    initDataJsonIfstream.close();

    std::clog << "***Check Init Data***" << std::endl;
    std::clog << "user: " << initData["dataBaseLoginData"]["user"].asString() << std::endl;
    std::clog << "dbname: " << initData["dataBaseLoginData"]["dbname"].asString() << std::endl;
    std::clog << "password: " << initData["dataBaseLoginData"]["password"].asString() << std::endl;
    std::clog << "ip: " << initData["ip"].asString() << std::endl;
    std::clog << "port: " << initData["port"].asInt() << std::endl;
    std::clog << "docRoot: " << initData["docRoot"].asString() << std::endl;
    std::clog << "***End Check Init Data***" << std::endl;
}