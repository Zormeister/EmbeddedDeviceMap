/*
 * Copyright (c) 2025, Zormeister
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <cstdio>
#include <cstring>
#include <json/config.h>
#include <json/json.h>
#include <json/reader.h>
#include <filesystem>
#include <json/value.h>
#include <fstream>
#include <json/writer.h>
#include <iostream>

//
// targetcompiler --targets <path/to/target/directory> --output <path/to/output>.json
//

std::filesystem::path targetPath;
std::filesystem::path outputPath;

Json::Value outputRoot(Json::arrayValue);

bool gVerboseLog = false;

/* */
void ProcessFile(std::filesystem::path filePath) {
    Json::CharReaderBuilder builder;
    Json::Value docRoot;
    auto size = std::filesystem::file_size(filePath);
    std::vector<char> vec(size);

    if (gVerboseLog) {
        printf("targetcompiler: Processing %s\n", filePath.c_str());
    }

    std::fstream stream;
    stream.open(filePath);
        // i assume im not trying to write any new data. i just want to parse it in memory.
    stream.read((char *)vec.data(), size);

    stream.close();

    auto rdr = builder.newCharReader();
    std::string err;
    rdr->parse(vec.data(), (vec.data() + size), &docRoot, &err);
    std::cout << err;
    
    if (docRoot.isArray()) {
        for (int i = 0; i < docRoot.size(); i++) {
            Json::Value val = docRoot.get(i, Json::nullValue);
            outputRoot.append(val);
        }
    }

    delete rdr;
}

void ProcessDirectory(std::filesystem::path directory) {
    for (auto &entry : std::filesystem::recursive_directory_iterator(directory)) {
        auto path = entry.path();
        size_t len = strlen(path.c_str());
        len -= 5;
        if (strncmp(path.c_str() + len, ".json", 5) == 0) {
            ProcessFile(path);
        }
    }
}

void ParseArgs(int argc, const char *argv[]) {
    for (int i = 0; i < argc; i++) {
        std::string str(argv[i]);
        if (str == "--targets" || str == "-t") {
            if (argc > (i + 1)) {
                targetPath = argv[i + 1];
            }
        } else if (str == "--output" || str == "-o") {
            if (argc > (i + 1)) {
                outputPath = argv[i + 1];
            }
        } else if (str == "-v") {
            gVerboseLog = true;
        }
    }
}

void PrintUsage(void) {
    printf("Usage: targetcompiler\n");
    printf("Options:\n");
    printf("  --targets (-t) | Path to the Targets directory.\n");
    printf("  --output  (-o) | Path to the output JSON file.\n");
    printf("  -v             | Print out all processed files.\n");
}

int main(int argc, const char *argv[]) {
    ParseArgs(argc, argv);

    if (!targetPath.c_str() || !outputPath.c_str()) {
        PrintUsage();
        return -1;
    }

    ProcessDirectory(targetPath);
    Json::StreamWriterBuilder builder;
    auto writer = builder.newStreamWriter();
    std::ofstream stream;
    stream.open(outputPath);
    writer->write(outputRoot, &stream);
    stream.close();

    return 0;
}