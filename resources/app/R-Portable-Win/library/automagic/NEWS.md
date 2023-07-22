## automagic v0.5.1

- added back `install_package_guess`, but removed ability to installed packages from GitHub based on a guess


## automagic v0.5

- Deprecated the ability to install github packages with `install_package_guess` as it was causing installation problems on older versions of R due to `githubinstall`
- Fixed bug where duplicate packages would be returned if parsing more than one file in a folder
- Fixed bug where deps.yaml file with no github packages would fail
- Fixed bug that would duplicate packages in deps.yaml when parsing more than one file in a folder
