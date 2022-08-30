#pragma once

#include <iostream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void Add(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient);