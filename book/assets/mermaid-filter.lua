local function has_class(classes, wanted)
  for _, class in ipairs(classes) do
    if class == wanted then return true end
  end
  return false
end

local function escape_html(text)
  return text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

function CodeBlock(block)
  if has_class(block.classes, "mermaid") then
    return pandoc.RawBlock(
      "html",
      '<figure class="diagram"><pre class="mermaid">'
        .. escape_html(block.text)
        .. '</pre></figure>'
    )
  end
end

