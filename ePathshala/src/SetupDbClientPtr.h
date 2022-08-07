#pragma once

#include <iostream>
#include <sstream>
#include <json/json.h>
#include <drogon/orm/DbClient.h>

drogon::orm::DbClientPtr GetDbClientPtr(Json::Value &initValue);