#pragma once

#include <iostream>
#include <fstream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void Login(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient);