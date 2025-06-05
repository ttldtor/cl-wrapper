# cl-wrapper

**cl-wrapper** is a wrapper around `cl.exe` (the Microsoft Visual C++ compiler), allowing you to apply a set of strategies to its arguments before execution.
It's useful for automating builds, modifying compiler flags (e.g., replacing `/MD` with `/MT`), and filtering problematic arguments when using tools like GraalVM `native-image`.

> License: BSL-1.0  
> Platform: Windows only  
> Language: [D Programming Language](https://dlang.org/)

---

## Features

- Intercepts and modifies compiler arguments
- Automatically replaces `/MD` → `/MT`
- Strips `NODEFAULTLIB:libcmt.lib` when needed
- Easily configurable via environment variables

---

## Usage

### 1. Store the original `cl.exe` path

Before using the wrapper, you should store the real path to `cl.exe`:

```cmd
cl-wrapper.exe --store
```

This saves the compiler path to a text file named orig_cl_path.txt.

To override the default file name, set the following environment variable:

```cmd
set CLWRPR_DEFAULT_ORIG_CL_PATH_FILENAME=some_path.txt
```

### 2. Set argument transformation strategies

Specify one or more strategies via the `CLWRPR_STRATEGIES` environment variable:

```cmd
set CLWRPR_STRATEGIES=MD2MT
```

Multiple strategies can be separated by commas:

```cmd
set CLWRPR_STRATEGIES=MD2MT,None
```

### 3. Compile as usual using `cl-wrapper.exe`

Run the wrapper with the arguments intended for `cl.exe`:

```cmd
cl-wrapper.exe /nologo /c hello.cpp /MD /Fohello.obj
```

If no stored path is found, `cl-wrapper` will default to using `cl.exe` from the system `PATH`.

---

## Example: MD2MT strategy

Transforms:

```
/MD     → /MT
/MDd    → /MTd
/NODEFAULTLIB:libcmt.lib → removed
/NODEFAULTLIB:libcmt     → removed
/NODEFAULTLIB:msvcrt.lib         → added
/NODEFAULTLIB:msvcrtd.lib        → added
/NODEFAULTLIB:msvcp.lib          → added
/NODEFAULTLIB:msvcpd.lib         → added
/NODEFAULTLIB:vcruntime.lib      → added
/NODEFAULTLIB:vcruntime140.lib   → added
/NODEFAULTLIB:vcruntime140_1.lib → added
/NODEFAULTLIB:ucrt.lib           → added
/NODEFAULTLIB:ucrtd.lib          → added
/NODEFAULTLIB:ucrtbase.lib       → added
/NODEFAULTLIB:api-ms-win-crt-convert-l1-1-0.lib     → added
/NODEFAULTLIB:api-ms-win-crt-environment-l1-1-0.lib → added
/NODEFAULTLIB:api-ms-win-crt-filesystem-l1-1-0.lib  → added
/NODEFAULTLIB:api-ms-win-crt-heap-l1-1-0.lib        → added
/NODEFAULTLIB:api-ms-win-crt-runtime-l1-1-0.lib     → added
/NODEFAULTLIB:api-ms-win-crt-stdio-l1-1-0.lib       → added
/NODEFAULTLIB:api-ms-win-crt-string-l1-1-0.lib      → added
```

---

## Environment Variables

| Variable                                 | Description                                                 |
| ---------------------------------------- | ----------------------------------------------------------- |
| `CLWRPR_STRATEGIES`                      | Comma-separated list of strategies to apply (e.g., `MD2MT`) |
| `CLWRPR_DEFAULT_ORIG_CL_PATH_FILENAME`   | Name of the file that stores the original path to `cl.exe`  |
| `CLWRPR_MD2MT_STRATEGY_ADD_NODEFAULTLIB` | A comma-separated list of libraries that will be specified to the linker using the `/NODEFAULTLIB` flags when processing arguments with the `MD2MT` strategy.  |
| `CLWRPR_MD2MT_STRATEGY_ADD_DEFAULTLIB`  | A comma-separated list of libraries that will be specified to the linker using the `/DEFAULTLIB` flags when processing arguments with the `MD2MT` strategy.  |


---

## Use Case: GraalVM native-image

This tool is especially useful when GraalVM `native-image` builds native binaries using `cl.exe` and you want to customize or override compiler behavior — e.g., forcing static linking via `/MT`.
The utility is launched in the context of the Visual Studio shell (`vcvars*.bat`) using the maven step, so `cl.exe` will be in the path. In extreme cases, `cl-wrapper.exe` can be changed to `cl.exe`

---

## License

Licensed under the [Boost Software License 1.0 (BSL-1.0)](https://chatgpt.com/c/LICENSE.txt).
