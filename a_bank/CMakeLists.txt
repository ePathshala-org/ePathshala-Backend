cmake_minimum_required(VERSION 3.0.0)
project(a_bank VERSION 0.1.0)

file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/sql ${CMAKE_BINARY_DIR}/data)
file(COPY ${CMAKE_SOURCE_DIR}/sql DESTINATION ${CMAKE_BINARY_DIR})

add_executable(a_bank
    "src/main.cpp"
    "src/Subtract.cpp"
    "src/Add.cpp"
)

find_package(Drogon REQUIRED)
target_link_libraries(a_bank Drogon::Drogon)