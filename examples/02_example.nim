import packy

const list = @[r"dep1\linux\dep1.linux.png", r"dep1\linux\dep1.linux.wav",
    r"dep2\linux\dep2.linux.png", r"dep2\linux\dep2.linux.wav"]

# pass a seq of file names
packDep(list)

#[ the followning would also be valid
packDep(list, architecture = "amd64", operatingSystem = "linux" ) ]#
