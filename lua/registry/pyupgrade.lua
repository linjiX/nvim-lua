local Pkg = require("mason-core.package")
local pip3 = require("mason-core.managers.pip3")

return Pkg.new({
    name = "pyupgrade",
    desc = "A tool to automatically upgrade syntax for newer versions.",
    homepage = "https://pypi.org/project/pyupgrade/",
    languages = { Pkg.Lang.Python },
    categories = { Pkg.Cat.Formatter },
    install = pip3.packages({ "pyupgrade", bin = { "pyupgrade" } }),
})
