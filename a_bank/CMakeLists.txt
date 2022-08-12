cmake_minimum_required(VERSION 3.0.0)
project(a_bank VERSION 0.1.0)

add_executable(a_bank
    "src/main.cpp"
)

find_package(Drogon REQUIRED)
target_link_libraries(a_bank Drogon::Drogon)