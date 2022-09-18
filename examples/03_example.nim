import packy

# note .dll files were passed
# examine the created "03_example_installer.nim" to see reults
packDep(r"dep1\win64\dep1.win64.dll")
packDep(r"dep2\win64\dep2.win64.dll")
packDep(r"dep2\win64\dep2.win64.wav")
packDep(r"dep1\win64\dep1.win64.png")
