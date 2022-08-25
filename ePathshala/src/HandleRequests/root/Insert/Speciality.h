#pragma once

#include <iostream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void InsertSpeciality(Json::Value &request, drogon::orm::DbClient &dbClient);