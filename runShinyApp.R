.libPaths("./R-Portable-Win/library")
# the path to portable chrome
#browser.path = file.path(getwd(),"GoogleChromePortable/GoogleChromePortable.exe")
#options(browser = browser.path)
message('library paths:\n', paste('... ', .libPaths(), sep='', collapse='\n'))
chrome.portable = file.path(getwd(),
                            'GoogleChromePortable/App/Chrome-bin/chrome.exe')
launch.browser = function(appUrl, browser.path=chrome.portable) {
    message('Browser path: ', browser.path)
    shell(sprintf('"%s" --app=%s', browser.path, appUrl))
}
shiny::runApp('./shiny/', launch.browser=launch.browser)