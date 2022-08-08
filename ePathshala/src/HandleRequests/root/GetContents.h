#pragma once

#include <iostream>
#include <fstream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void GetContents(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient);