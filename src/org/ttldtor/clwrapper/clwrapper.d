// Copyright (c) 2025 ttldtor.
// SPDX-License-Identifier: BSL-1.0

module org.ttldtor.clwrapper.clwrapper;

import std.stdio;
import std.process;
import std.string;
import std.file;
import std.algorithm;
import std.logger.core;

void toTextFile(string data, string fileName) {
    std.algorithm.mutation.copy(data, File(fileName, "w").lockingTextWriter);
}

version (Windows) {

enum STORE_ORIG_CL_PATH_PARAM = "--store";
enum ENV_DEFAULT_ORIG_CL_PATH_FILENAME = "CW_DEFAULT_ORIG_CL_PATH_FILENAME";
enum DEFAULT_ORIG_CL_PATH = "orig_cl_path.txt";


void storeOriginalClPath(string origClPathFilename) {
    //enum whichCl = `powershell.exe -Command "Get-Command cl.exe | Select-Object -ExpandProperty Source"`;
    enum whichCl = `cmd /c where cl.exe`;

    auto result = whichCl.executeShell;

    if (result.status == 0) {
        auto originalClPath = result.output.strip;

        infof("The original cl.exe path: '%s'", originalClPath);
        originalClPath.toTextFile(origClPathFilename);
    } else {
        "cl.exe is not found!".error;
    }
}

string loadOriginalClPath(string origClPathFilename) {
    if (origClPathFilename.exists) {
        return origClPathFilename.readText;
    }

    return "";
}

auto runCl(scope const(char[])[] args) {
    auto cl = args.execute;

    if (cl.status != 0) {
        error("Compilation failed:\n", cl.output);
    } else {
        cl.output.writeln;
    }

    return cl.status;    
}

int main(string[] args) {
    import std.uni;
 
    string origClPathFilename = environment.get(ENV_DEFAULT_ORIG_CL_PATH_FILENAME, DEFAULT_ORIG_CL_PATH);

    infof("The original cl.exe path filename: '%s'", origClPathFilename);

    if (args.length > 1 && args[1].icmp(STORE_ORIG_CL_PATH_PARAM) == 0) {
        storeOriginalClPath(origClPathFilename);

        return 0;
    }

    string pathToOrigCl = origClPathFilename.loadOriginalClPath;

    if (pathToOrigCl.length > 0) {
        if (args.length > 1) {
            return ([pathToOrigCl] ~ args[1 .. $]).runCl;
        } else {
            return [pathToOrigCl].runCl;
        }
    }

    error("There is nothing to run. The path to the original cl.exe was not saved." ~ 
            "The program may not have been run in the context of Command Prompt for VS");

    return 1;
}

} else {

    int main() {
        "Non windows".error;

        return 1;
    }

}
