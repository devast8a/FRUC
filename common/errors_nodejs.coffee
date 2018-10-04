fs = require 'fs'
path = require 'path'

exports.findPackageJson =
findPackageJson = (dir)->
    try
        dir = path.resolve dir

        while true
            last = dir
            dir = path.dirname dir

            if last == dir
                return null

            pkg = path.join dir, 'package.json'

            if fs.existsSync pkg
                return require pkg

exports.lookupPackageByPath =
lookupPackageByPath = (file)->
    for key of require.cache
        pkg = require.cache[key]

        if pkg.id == file
            return findPackageJson pkg.id
    return null

exports.findBlameInfo =
findBlameInfo = (file)->
    pkg = lookupPackageByPath file

    if not pkg?
        return []

    try
        info = []

        # Try the best candidates first
        # package.bugs.url
        if pkg.bugs?.url?
            info.push
                type: "Issue Tracker"
                data: pkg.bugs.url
            return info

        # package.repository
        if pkg.repository?
            info.push
                type: "Repository"
                data: pkg.repository
            return info

        # package.bugs.email
        if pkg.bugs?.email?
            info.push
                type: "Email"
                data: pkg.bugs.email
            return info

        # Otherwise try find emails
        if pkg.contributors?
            for contributor in pkg.contributors
                if contributor.email?
                    info.push
                        type: "Email"
                        data: contributor.email

        # package.author.email
        if typeof(pkg.author) == 'object' and pkg.author.email?
            info.push
                type: "Email"
                data: pkg.author.email
    catch

    # Limit to first 5 results
    return info[..5]
