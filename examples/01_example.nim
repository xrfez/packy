import packy

# compile time environment are passed as OS and Architecture
packDep(r"dep1\linux\dep1.linux.png")
packDep(r"dep1\linux\dep1.linux.wav", "sound")

# these will ony be unpacked if runtime environment matches arguments
packDep(r"dep2\linux\dep2.linux.png", "", "linux")
packDep(r"dep2\linux\dep2.linux.wav", "sound", "linux", "amd64")

