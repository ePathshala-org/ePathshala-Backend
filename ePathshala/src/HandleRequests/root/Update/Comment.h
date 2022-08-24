#pragma once

#include <iostream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void UpdateComment(Json::Value &request, drogon::orm::DbClient &dbClient);