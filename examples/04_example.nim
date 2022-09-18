import packy

# to not pack some dependencies that will not be needed
# at runtime.
when defined(windows) and defined(amd64):
  packDep(r"dep1\win64\dep1.win64.dll")
  packDep(r"dep2\win64\dep2.win64.dll")
  packDep(r"dep2\win64\dep2.win64.wav")
  packDep(r"dep1\win64\dep1.win64.png")

when defined(windows) and defined(i386):
  packDep(r"dep1\win32\dep1.win32.dll")
  packDep(r"dep2\win32\dep2.win32.dll")
  packDep(r"dep2\win32\dep2.win32.wav")
  packDep(r"dep1\win32\dep1.win32.png")

when defined(linux) and defined(amd64):
  packDep(r"dep1\win32\dep1.win32.wav")
  packDep(r"dep2\win32\dep2.win32.png")
  packDep(r"dep2\win32\dep2.win32.wav")
  packDep(r"dep1\win32\dep1.win32.png")
