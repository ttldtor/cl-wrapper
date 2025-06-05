// Copyright (c) 2025 ttldtor.
// SPDX-License-Identifier: BSL-1.0

module org.ttldtor.clwrapper.clwrapper;

import std.stdio;
import std.process;
import std.string;
import std.file;
import std.algorithm;
import std.logger.core;
import std.array;
import std.typecons;
import std.conv;
import std.regex;

void toTextFile(string data, string fileName) {
    std.algorithm.mutation.copy(data, File(fileName, "w").lockingTextWriter);
}

version (Windows) {

enum STORE_ORIG_CL_PATH_PARAM = "--store";

enum ENV_DEFAULT_ORIG_CL_PATH_FILENAME = "CLWRPR_DEFAULT_ORIG_CL_PATH_FILENAME";
enum DEFAULT_ORIG_CL_PATH = "orig_cl_path.txt";

enum ENV_STRATEGIES = "CLWRPR_STRATEGIES";

interface Strategy {
    string getName() const;
    string[] apply(const string[] args) const;
}

class MdToMtStrategy : Strategy {
    string getName() const {
        return "MD2MT";
    }

    string[] apply(const string[] args) const {
        if (args.length == 0) {
            return [];
        }

        string[] result;

        foreach (arg; args) {
            string fixedArg = arg;

            if (arg.match(r"^/MDd?$")) {
                fixedArg = arg.replace("/MD", "/MT");
            } else if (arg.match(r"(?i)^/NODEFAULTLIB:libcmt(?:\.lib)?$")) {
                continue;
            }

            result ~= fixedArg;
        }

        return result.dup;
    }
};

class NoneStrategy : Strategy {
    string getName() const {
        return "None";
    }

    string[] apply(const string[] args) const {
        return args.dup;
    }
};

static const STRATEGIES = [ new MdToMtStrategy(), new NoneStrategy() ]
    .to!(Strategy[])
    .map!(s => tuple(s.getName(), s))
    .assocArray;

string[] applyStrategies(const string[] strategyNamesToApply, const string[] args) {
    auto argsCopy = args.dup;

    infof("Strategies to apply: %s", strategyNamesToApply);

    if (strategyNamesToApply.length > 0) {
        foreach (name; strategyNamesToApply) {
            infof("Args: %s", argsCopy);
            infof("Strategy: %s", name);

            auto s = name in STRATEGIES;

            if (s !is null) {
                argsCopy = (*s).apply(argsCopy);
            }

            infof("Args: %s", argsCopy);
        }
    } else {
        infof("Args: %s", argsCopy);
    }

    return argsCopy.dup;
}

void storeOriginalClPath(string origClPathFilename) {
    //enum whichCl = `powershell.exe -Command "Get-Command cl.exe | Select-Object -ExpandProperty Source"`;
    enum whichCl = `cmd /c where cl.exe`;

    auto result = whichCl.executeShell();

    if (result.status == 0) {
        auto originalClPath = result.output.strip();

        infof("The original cl.exe path: '%s'", originalClPath);
        originalClPath.toTextFile(origClPathFilename);
    } else {
        "cl.exe is not found!".error;
    }
}

string loadOriginalClPath(string origClPathFilename) {
    if (origClPathFilename.exists) {
        return origClPathFilename.readText();
    }

    return "cl.exe";
}

alias originalClPath = loadOriginalClPath;

auto runCl(scope const(char[])[] args) {
    auto cl = args.execute();

    if (cl.status != 0) {
        error("Compilation failed:\n", cl.output);
    } else {
        cl.output.info();
    }

    return cl.status;    
}

int main(string[] args) {
    import std.uni;

    infof("Available strategies: %s", STRATEGIES);
 
    string origClPathFilename = environment.get(ENV_DEFAULT_ORIG_CL_PATH_FILENAME, DEFAULT_ORIG_CL_PATH);

    infof("The original cl.exe path filename: '%s'", origClPathFilename);

    if (args.length > 1 && args[1].icmp(STORE_ORIG_CL_PATH_PARAM) == 0) {
        origClPathFilename.storeOriginalClPath();

        return 0;
    }

    string pathToOrigCl = origClPathFilename.originalClPath;

    if (pathToOrigCl.length > 0) {
        if (args.length > 1) {
            auto strategyNamesToApply = environment.get(ENV_STRATEGIES, new NoneStrategy().getName).split(",");
            auto processedArgs = strategyNamesToApply.applyStrategies(args[1 .. $].dup);

            return (pathToOrigCl ~ processedArgs).runCl();
        } else {
            return [pathToOrigCl].runCl();
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
