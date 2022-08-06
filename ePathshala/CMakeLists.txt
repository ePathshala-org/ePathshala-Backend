cmake_minimum_required(VERSION 3.0.0)
project(ePathshala VERSION 0.1.0)

add_executable(ePathshala
    src/main.cpp
    src/SetupInitData.cpp
    src/SetupDbClientPtr.cpp)

find_package(Drogon REQUIRED)
target_link_libraries(ePathshala Drogon::Drogon)

file(COPY ${CMAKE_SOURCE_DIR}/sql DESTINATION ${CMAKE_BINARY_DIR})