return {
    name = "pyupgrade",
    description = "A tool to automatically upgrade syntax for newer versions.",
    homepage = "https://pypi.org/project/pyupgrade/",
    licenses = { "MIT" },
    languages = { "Python" },
    categories = { "Formatter" },
    source = {
        id = "pkg:pypi/pyupgrade@3.20.0",
    },
    bin = {
        pyupgrade = "pypi:pyupgrade",
    },
}
