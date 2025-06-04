# cl-wrapper

**cl-wrapper** is a wrapper around `cl.exe` (the Microsoft Visual C++ compiler), allowing you to apply a set of strategies to its arguments before execution.
It's useful for automating builds, modifying compiler flags (e.g., replacing `/MD` with `/MT`), and filtering problematic arguments when using tools like GraalVM `native-image`.

> 🪪 License: BSL-1.0  
> 🪟 Platform: Windows only  
> 🧠 Language: [D Programming Language](https://dlang.org/)

---

## 📦 Features

- Intercepts and modifies compiler arguments
- Automatically replaces `/MD` → `/MT`
- Strips `NODEFAULTLIB:libcmt.lib` when needed
- Easily configurable via environment variables

---

## ⚙️ Usage

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

## 🧪 Example: MD2MT strategy

Transforms:

```
/MD     → /MT
/MDd    → /MTd
/NODEFAULTLIB:libcmt.lib → removed
/NODEFAULTLIB:libcmt     → removed
```

---

## 🧰 Environment Variables

| Variable                               | Description                                                 |
| -------------------------------------- | ----------------------------------------------------------- |
| `CLWRPR_STRATEGIES`                    | Comma-separated list of strategies to apply (e.g., `MD2MT`) |
| `CLWRPR_DEFAULT_ORIG_CL_PATH_FILENAME` | Name of the file that stores the original path to `cl.exe`  |


---

## 💡 Use Case: GraalVM native-image

This tool is especially useful when GraalVM `native-image` builds native binaries using `cl.exe` and you want to customize or override compiler behavior — e.g., forcing static linking via `/MT`.

---

## 📜 License

Licensed under the [Boost Software License 1.0 (BSL-1.0)](https://chatgpt.com/c/LICENSE.txt).
