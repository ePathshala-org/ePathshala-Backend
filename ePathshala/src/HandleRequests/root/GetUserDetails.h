#pragma once

#include <iostream>
#include <fstream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void GetUserDetails(Json::Value &requestJson, Json::Value &reponse, drogon::orm::DbClient &dbClient);