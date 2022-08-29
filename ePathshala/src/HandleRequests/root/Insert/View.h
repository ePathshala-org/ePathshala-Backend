#pragma once

#include <iostream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void InsertView(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient);