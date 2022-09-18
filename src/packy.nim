import std/[os, macros, strutils, compilesettings]

type
  StoredDependency {.packed.} = object
    fileName: string
    subDir: string
    os: string
    cpu: string
    packedDependency: string

var ForceOverwrite*: bool = false
  ## packy flag for unpacking

proc replaceSymAndIdent(a: NimNode, b: NimNode, c: NimNode, isLit: static[bool] = true) =
  for i in 0..len(a)-1:
    if a[i].kind == nnkSym:
      if ident(strVal(a[i])) == b:
        a[i] = c
    elif a[i].kind == nnkClosedSymChoice or a[i].kind == nnkOpenSymChoice:
      if ident(strVal(a[i][^1])) == b:
        a[i] = c
    elif a[i].kind == nnkIdent:
      if a[i] == b:
        a[i] = c
    elif a[i].len != 0:
      if a[i].kind == nnkDotExpr:
        when not isLit:
          if a[i][0].kind == nnkSym:
            if ident(strVal(a[i][0])) == b:
              a[i][0] = c
          elif a[i][0].kind == nnkClosedSymChoice or a[i][0].kind == nnkOpenSymChoice:
            if ident(strVal(a[i][0][^1])) == b:
              a[i][0] = c
          elif a[i][0].kind == nnkIdent:
            if a[i][0] == b:
              a[i][0] = c
      else:
        replaceSymAndIdent(a[i], b, c, isLit)

macro iterateSeq*(a: untyped, b: static[seq[string]], code: untyped): untyped =
  ## Compile Time iterator for `seq[string]`  Not to be used in a for loop.
  ## Usage ```iterateSeq(string, seq[string]):
  ##            packDep(string) ```
  let a =
    if a.kind == nnkSym:
      ident($a)
    elif a.kind == nnkClosedSymChoice or a.kind == nnkOpenSymChoice:
      ident($a[^1])
    else:
      a
  result = newStmtList()
  for item in b:
    var newCode = code.copy()
    replaceSymAndIdent(newCode, a, newLit(item), isLit = true)
    result.add(newCode)

template packDep*(file: string, folder: string = "",
    operatingSystem: string = hostOS, architecture: string = hostCPU) =
  ## Will bundle dependency into the binary at compile time and unpack it at runtime
  ## in the location of the binary.  A file will be created `[srcName]_installer.nim` packing
  ## any `.dll` files along with the final binary.  This can be compiled and shipped standalone
  ## if `.dll` files are required.
  ##
  ## The `operatingSystem` and `architecture` arguments
  ## can be configured to suit the dependency or default to the parameters of the host compiler
  ## environment and will only be unpacked if both criteria are met at runtime.
  ##
  ## operatingSystem: "windows"|"macosx"|"linux"|"netbsd"|"freebsd"|"openbsd"|"solaris"|"aix"|"haiku"|"standalone"
  ##
  ## architecture: "i386"|"alpha"|"powerpc"|"powerpc64"|"powerpc64el"|"sparc"|"amd64"|"mips"|"mipsel"|"arm"|"arm64"|"mips64"|"mips64el"|"riscv32"|"riscv64"
  const fileContents = slurp(normalizedPath(file))
  const dependency = StoredDependency(
      fileName: extractFilename(file),
      subDir: normalizedPath(folder),
      os: operatingSystem,
      cpu: architecture,
      packedDependency: fileContents
    )
  doAssert isValidFilename(dependency.fileName)

  # compile time create installer file
  const srcFile = instantiationInfo().filename[0..^5]
  const installFile = srcFile & "_installer.nim"
  when not fileExists(installFile):
    static: writeFile(installFile, "import std/os, packy \n" &
        "ForceOverwrite = true \n" & """packDep(r"""" & joinPath(querySetting(
        outDir), querySetting(outFile)) & """") """ & "\n" &
        """discard execShellCmd("""" & querySetting(outFile) & """")""")

  # compile time update installer file
  when dependency.fileName[^4..^1] == ".dll":
    const installerContents = slurp(installFile)
    static: writeFile(installFile, installerContents[0..<find(installerContents,
        "discard")] & """packDep(r"""" & normalizedPath(file) & """","""" &
            dependency.subDir & """","""" & dependency.os & """","""" &
            dependency.cpu & """") """ & "\n" &
        installerContents[find(installerContents, "discard")..^1])

  # runtime dump dependency
  if not fileExists(joinPath(dependency.subDir,
      dependency.fileName)):
    for p in parentDirs(dependency.subDir, fromRoot = true):
      if not dirExists(p): createDir(p)
    if hostOS == dependency.os and hostCPU == dependency.cpu:
      writeFile(joinPath(getAppDir(), dependency.subDir,
          dependency.fileName), dependency.packedDependency)
  if ForceOverwrite:
    for p in parentDirs(dependency.subDir, fromRoot = true):
      if not dirExists(p): createDir(p)
    if hostOS == dependency.os and hostCPU == dependency.cpu:
      writeFile(joinPath(getAppDir(), dependency.subDir,
          dependency.fileName), dependency.packedDependency)

template packDep*(files: seq[string], folder: string = "",
    operatingSystem: string = hostOS, architecture: string = hostCPU) =
  ## Will bundle dependencies into the binary at compile time and unpack them at runtime
  ## in the location of the binary.  A file will be created `[srcName]_installer.nim` packing
  ## any `.dll` files along with the final binary.  This can be compiled and shipped standalone
  ## if `.dll` files are required.
  ##
  ## The `operatingSystem` and `architecture` arguments
  ## can be configured to suit the dependency or default to the parameters of the host compiler
  ## environment and will only be unpacked if both criteria are met at runtime.
  ##
  ## operatingSystem: "windows"|"macosx"|"linux"|"netbsd"|"freebsd"|"openbsd"|"solaris"|"aix"|"haiku"|"standalone"
  ##
  ## architecture: "i386"|"alpha"|"powerpc"|"powerpc64"|"powerpc64el"|"sparc"|"amd64"|"mips"|"mipsel"|"arm"|"arm64"|"mips64"|"mips64el"|"riscv32"|"riscv64"
  iterateSeq(file, files):
    packDep(file, folder, operatingSystem, architecture)
