-- multicode.lua (v3) — Tabbed sections like qna, without duplicate outputs
-- Creates tabs either via Quarto's custom Tabset node (preferred) or
-- falls back to emitting a `.panel-tabset` div that Quarto will transform.
-- It accepts **both** `.multicode` and `.qna` divs (drop-in replacement).
-- It also reads both `multicode:` and `qna:` metadata for target selection.

-- =====================
-- Meta options (mirrors qna):
--   html/pdf/ipynb: 'both' | 'question' | 'answer'
-- Per-block override:  ::: {.multicode target="question"}
-- =====================

local target_html  = nil
local target_pdf   = nil
local target_ipynb = nil

local function norm(v)
  if v == nil then return nil end
  v = pandoc.utils.stringify(v):lower()
  if v == 'all' then return 'both' end
  if v == 'first' or v == 'q' then return 'question' end
  if v == 'second' or v == 'a' then return 'answer' end
  if v == 'both' or v == 'question' or v == 'answer' then return v end
  return 'both'
end

Meta = function(meta)
  -- Prefer `multicode:` meta; fall back to `qna:` if present
  local m = meta.multicode or meta.qna
  if m ~= nil and type(m) == 'table' then
    if m.html  ~= nil then target_html  = norm(m.html)  end
    if m.pdf   ~= nil then target_pdf   = norm(m.pdf)   end
    if m.ipynb ~= nil then target_ipynb = norm(m.ipynb) end
  end
end

local function format_target(default)
  if quarto and quarto.doc and quarto.doc.is_format then
    if quarto.doc.is_format('html') then
      return target_html or default
    elseif quarto.doc.is_format('pdf') then
      return target_pdf or default
    elseif quarto.doc.is_format('ipynb') then
      return target_ipynb or default
    end
  end
  return default
end

-- Split blocks into tabs based on the first header level seen
local function split_by_header(blocks)
  local tabs = {}
  local current = nil
  local base_level = nil

  for _, blk in ipairs(blocks) do
    if blk.t == 'Header' then
      if base_level == nil then base_level = blk.level end
      if blk.level == base_level then
        if current ~= nil then table.insert(tabs, current) end
        current = { title = blk.content, content = {} }
        -- Header becomes the tab title; exclude it from content
      else
        if current == nil then
          current = { title = pandoc.Inlines({ pandoc.Str('Section') }), content = {} }
        end
        table.insert(current.content, blk)
      end
    else
      if current == nil then
        current = { title = pandoc.Inlines({ pandoc.Str('Section') }), content = {} }
      end
      table.insert(current.content, blk)
    end
  end

  if current ~= nil then table.insert(tabs, current) end
  return tabs, (base_level or 3)
end

local function select_tabs(tabs, which)
  if which == 'question' and #tabs >= 1 then
    return { tabs[1] }
  elseif which == 'answer' and #tabs >= 2 then
    return { tabs[2] }
  else
    return tabs -- 'both' or other sizes
  end
end

local function has_class(el, cls)
  return el.classes and el.classes:includes(cls)
end

function Div(el)
  -- Accept both .multicode and .qna as triggers
  if not (has_class(el, 'multicode') or has_class(el, 'qna')) then
    return nil
  end

  -- Per-div override: target="both|question|answer"
  local which = norm(el.attributes and el.attributes['target']) or format_target('both')

  local tabs, level = split_by_header(el.content)
  if #tabs == 0 then
    return nil
  end

  tabs = select_tabs(tabs, which)

  -- Match qna’s look: level 3 and classes include 'panel-tabset' and 'qna-question'
  local tab_level = 3
  local classes = pandoc.List({ 'panel-tabset', 'qna-question' })
  if not has_class(el, 'qna') then classes:insert('multicode') end
  local attr = pandoc.Attr('', classes, {})

  if #tabs == 1 then
    -- Single section (no tabs): header + content, with qna-like class
    local hdr = pandoc.Header(tab_level, tabs[1].title, pandoc.Attr('', {'qna-question'}, {}))
    local out = { hdr }
    for _, b in ipairs(tabs[1].content) do table.insert(out, b) end
    return out
  end

  -- Preferred path: use Quarto custom node if available
  if quarto and quarto.Tabset and quarto.Tab then
    local qtabs = pandoc.List()
    for _, t in ipairs(tabs) do
      qtabs:insert(quarto.Tab({ title = t.title, content = t.content }))
    end
    return quarto.Tabset({ level = tab_level, tabs = qtabs, attr = attr })
  end

  -- Fallback: emit a `.panel-tabset` Div with repeated headers; Quarto will convert it
  local out_blocks = pandoc.List()
  for _, t in ipairs(tabs) do
    out_blocks:insert(pandoc.Header(tab_level, t.title))
    out_blocks:extend(t.content)
  end
  return pandoc.Div(out_blocks, attr)
end

return {
  { Meta = Meta },
  { Div  = Div  },
}
