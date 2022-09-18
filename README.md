# packy

`nimble install packy`

This library has no dependencies other than the Nim standard library

# About

packy is a module that allows the packing of dependencies into the compiled
binary and extracting them at runtime.  Allows the passing of target parameters 
with the dependencies, evaluated at runtime to determine what dependencies 
should be unpacked.  If no `.dll` files were packed then the resulting
executable is complete and can stand alone. 

This library offers a work around for `.dll` files.  During compile time a 
new file ending in `*_installer.nim` is created in the location of the source
file.  The file packs any `.dll`'s along with the executable from the 
initial compile.  This file can then be compilled and distributed alone.

# Usage

```nim
# Pass as a string
packDep("Path to dependency")
packDep("Path to dependency", "Sub-dir to unpack to")
packDep("Path to dependency", "Sub-dir to unpack to", "Operating System")
packDep("Path to dependency", "Sub-dir to unpack to", "OS", "Architecture")

# Pass a seq[string] / additional arguments applied to every dependency.
packDep(@["Path to dependency1", "Path to dependency2", "Path to dependency3"])

# Use compile time iterator. Useful if you need to modify the sequence prior
# can still pass additional arguments
iterateSeq(dependency, @["dependency1", "dependency2", "dependency3"])
  packDep("part1 of path" & dependency & "part2 of path")
```


