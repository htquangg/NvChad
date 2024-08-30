require("gitlinker").setup {
  mappings = "<space>gy",
  callbacks = {
    -- ["go.googlesource.com"] = function(url_data)
    --   local url = require("gitlinker.hosts").get_base_https_url(url_data)
    --   url = url .. "/+/" .. url_data.rev .. "/" .. url_data.file
    --   if url_data.lstart then
    --     url = url .. "#" .. url_data.lstart
    --   end
    --   return url
    -- end,
    ["github-nevel"] = function(url_data)
      url_data.host = "github.com"
      url_data.repo = "/" .. url_data.repo
      return require("gitlinker.hosts").get_github_type_url(url_data)
    end,
  },
}

