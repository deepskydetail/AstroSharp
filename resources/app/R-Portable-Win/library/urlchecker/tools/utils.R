### ** lines2str
lines2str <-
function(txt, sep = "")
    trimws(gsub("\n", sep, paste(txt, collapse = sep),
                fixed = TRUE, useBytes = TRUE))
