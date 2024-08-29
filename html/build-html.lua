local json = require "JSON"

local function readFile(args)

    local file = io.open(args, "r")
    io.input(file)
    local contents = io.read("*a")
    io.close(file)

    return contents
end

local function buildWhatsNew()

    -- load up our package listing
    local packages = json:decode(readFile("../packages/mpkg.packages.json"))

    -- html section preamble
    local whatsNewHtml = [[    <section id="pageContent">
        <main role="main">
        <h2>Recent Uploads</h2><br><br>]]

    -- sort packages by creation time, newest first
    local whatsNew = {}

    for file in io.popen([[ls -c ../packages/*.mpackage | head -n 5]]):lines() do
        local tempStr = string.gsub(file, "packages/", "")
        tempStr = string.gsub(tempStr, ".mpackage", "")
        table.insert(whatsNew, tempStr)
    end

    -- pull the 5 latest entries
    for j = 1, #whatsNew do
        for i = 1, #packages["packages"] do
            if packages["packages"][i]["mpackage"] == whatsNew[j] then
                whatsNewHtml = whatsNewHtml .. "            <article>\n"
                whatsNewHtml = whatsNewHtml .. "                <h2>" .. packages["packages"][i]["mpackage"] .. "</h2>\n"
                whatsNewHtml = whatsNewHtml .. "                <p>by " .. packages["packages"][i]["author"] .. ", version " .. packages["packages"][i]["version"] .. "</p><br><br>\n"
                whatsNewHtml = whatsNewHtml .. "                <p>" .. packages["packages"][i]["title"] .. "</p>\n"
                whatsNewHtml = whatsNewHtml .. "            </article>\n"
            end
        end
    end

    return whatsNewHtml
end

local function writeWebRepo()

    local header = readFile("web-repo-header.txt")
    local newPackagesList = buildWhatsNew()
    local footer = readFile("web-repo-footer.txt")

    local file = io.open("../index.html", "w+")
    io.output(file)

    io.write(readFile("web-repo-header.txt"))
    io.write(buildWhatsNew())
    io.write(readFile("web-repo-footer.txt"))

    io.close(file)

end

print("Building web pages for repository.")
writeWebRepo()
