#include "SetupDbClientPtr.h"

drogon::orm::DbClientPtr GetDbClientPtr(Json::Value &initValue)
{
    std::stringstream loginStringStream;

    loginStringStream << "user=" << initValue["dataBaseLoginData"]["user"].asString() << " password=" << initValue["dataBaseLoginData"]["password"].asString() << " dbname=" << initValue["dataBaseLoginData"]["dbname"].asString();

    std::cout << "Database Login String: \"" << loginStringStream.str() << "\"" << std::endl;

    return drogon::orm::DbClient::newPgClient(loginStringStream.str(), 1);
}