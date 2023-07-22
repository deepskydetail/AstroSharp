
# 1.2.2

* This version does not add an emoji hash to the output.

* The `source` column of the output data frame of `package_info()` (also
  part of `session_info()`), now contains the full SHA for packages installed
  from GitHub, instead of only the first seven characters. This makes it
  easier to use the SHA programmatically. Note that this does not affect
  formatting and printing, which still use the abbreviated SHA.
  (@muschellij2, #61).

* RStudio Package Manager (RSPM) and other repository sources are
  now shown in the `source` column, if they set the `Repository`
  field in `DESCRIPTION`.

# 1.2.1

* `package_info()` and `session_info()` now do not fail if the version
  number of an installed package is invalid.

* Better aliases for the list of attached, loaded and installed packages
  in `package_inf()` and `session_info()`.

# 1.2.0

* New function `external_info()`, information about external software.
  It can be also requested with the new `info` argument of
  `session_info()` (@llrs).

* New function `python_info()`, information about Python configuration.
  It is automatically included in `session_info()` if the reticulate
  package is loaded and Python is available. You can also request it
  manually via the new `info` argument of `session_info()` (#33).

* The output of `session_info()` now has an emoji hash, consisting of
  three emojis. This allows quick comparison of two session infos (#26).

* All `*_info()` functions use ANSI colors on systems that support them.
  In particular, it highlights unusual package versions and sources,
  and possible package problems (#3).

* New `session_diff()` function, to compare two session infos from
  various sources (#6).

* `session_info()` has a new argument named `info`, to select which parts
  of the session information should be printed.

* `session_info()` now has a `to_file` argument, to write the output to a
  file (#30).

* `session_inf()` has a `dependencies` argument now, and passes it to
  `package_info()`.

* `package_info()` and `session_info()` can now list the attached or
  installed packages, see the `pkgs` argument in the manual for
  details (#42).

* `platform_info()` and `session_info()` now include the Windows build
  number in the output (#40).

* sessioninfo now never wraps the output if the screen is too narrow (#31).

* All `*_info()` functions have a `format()` S3 method now.

* `platform_info()` and `session_info()` now include the RStudio version if
  the R session is in RStudio (#29).

* The `source` column of the package list is now more informative.

# 1.1.1

* `package_info()` and `session_info()` now detect locally installed packages 
  correctly if they have an empty `biocViews` field in `DESCRIPTION (@llrs, #25)

* `package_info()` and `session_info()` now handle the case when a loaded
  package was removed from the disk.

# 1.1.0

* `package_info()` now has a `dependencies` argument, to filter the type
  of dependent packages in the output (#22).

* `session_info()` and `package_info()` now show the library search path,
  and also which library each package was loaded from. They also warn
  if the on-disk version of the package has a different path than the
  loaded version (#9, #20).

* `package_info()`'s `ondiskversion` entry is now correct.

* `session_info()` and `package_info()` now verify the MD5 hashes of DLL
  files on Windows, and warns for micmatches, as these are usually
  broken packages (#12, #16).

* We use now the cli package, instead of clisymbols, and this fixes
  printing bugs in LaTeX documents (#14).

* `session_info()` and `platform_info()` now include the `LC_CTYPE`
  locale category (@patperry, #11)

* `session_info()` and `package_info()` now print source of the CRAN
  packages in uppercase, always, even if they were installed by devtools.

* `session_info()` and `platform_info()` now handle the case when
  `utils::sessionInfo()$running` is `NULL` (@HenrikBengtsson, #7).

* `session_info()` and `package_info()` now only list loaded versions
  for namespaces which are already loaded. This only makes a difference
  if the `pkgs` argument is given (#4).

* Do not consult the `max.print` option, for platform and package info
  (@jennybc, #13).

# 1.0.0

First public release.
