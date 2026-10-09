-- F1 Management (Pitwall Pro) para KOReader
-- Sin audio, sin animaciones, pensado para pantallas e-ink.

local WidgetContainer = require("ui/widget/container/widgetcontainer")
local ButtonDialog = require("ui/widget/buttondialog")
local InfoMessage = require("ui/widget/infomessage")
local InputDialog = require("ui/widget/inputdialog")
local UIManager = require("ui/uimanager")
local DataStorage = require("datastorage")
local LuaSettings = require("luasettings")
local _ = require("gettext")

local F1 = WidgetContainer:extend{
    name = "f1management",
    is_doc_only = false,
}

---------------------------------------------------------------------------
-- Datos
---------------------------------------------------------------------------

local PTS = { 25, 18, 15, 12, 10, 8, 6, 4, 2, 1 }

-- Grilla de referencia (verificar plantel vigente)
local AI = {
    { "Max Verstappen", "NL", "Red Bull", 95 },
    { "Yuki Tsunoda", "JP", "Red Bull", 79 },
    { "Lewis Hamilton", "GB", "Ferrari", 91 },
    { "Charles Leclerc", "MC", "Ferrari", 90 },
    { "Lando Norris", "GB", "McLaren", 93 },
    { "Oscar Piastri", "AU", "McLaren", 92 },
    { "George Russell", "GB", "Mercedes", 90 },
    { "Kimi Antonelli", "IT", "Mercedes", 84 },
    { "Fernando Alonso", "ES", "Aston Martin", 86 },
    { "Lance Stroll", "CA", "Aston Martin", 74 },
    { "Pierre Gasly", "FR", "Alpine", 81 },
    { "Franco Colapinto", "AR", "Alpine", 72 },
    { "Carlos Sainz", "ES", "Williams", 85 },
    { "Alexander Albon", "TH", "Williams", 80 },
    { "Liam Lawson", "NZ", "Racing Bulls", 78 },
    { "Isack Hadjar", "FR", "Racing Bulls", 70 },
    { "Esteban Ocon", "FR", "Haas", 77 },
    { "Nico Hülkenberg", "DE", "Audi", 80 },
    { "Gabriel Bortoleto", "BR", "Audi", 71 },
    { "Valtteri Bottas", "FI", "Cadillac", 73 },
    { "Sergio Pérez", "MX", "Cadillac", 75 },
}

-- Récords: referencia de memoria, verificar antes de publicar
local TRACKS = {
    { c = "Monza", p = "Italia", cc = "IT", lap = 81, rain = 25, r = "Rubens Barrichello", rc = "BR", ry = 2004, rt = "1:21.046" },
    { c = "Silverstone", p = "Reino Unido", cc = "GB", lap = 87, rain = 45, r = "Max Verstappen", rc = "NL", ry = 2020, rt = "1:27.097" },
    { c = "Spa-Francorchamps", p = "Bélgica", cc = "BE", lap = 101, rain = 60, r = "Valtteri Bottas", rc = "FI", ry = 2018, rt = "1:41.252" },
    { c = "Suzuka", p = "Japón", cc = "JP", lap = 90, rain = 40, r = "Lewis Hamilton", rc = "GB", ry = 2019, rt = "1:30.983" },
    { c = "Mónaco", p = "Mónaco", cc = "MC", lap = 72, rain = 30, r = "Lewis Hamilton", rc = "GB", ry = 2021, rt = "1:12.909" },
    { c = "Interlagos", p = "Brasil", cc = "BR", lap = 70, rain = 55, r = "Valtteri Bottas", rc = "FI", ry = 2018, rt = "1:10.540" },
}

local NATIONS = {
    { "AR", "Argentina" }, { "BR", "Brasil" }, { "MX", "México" }, { "ES", "España" },
    { "IT", "Italia" }, { "GB", "Reino Unido" }, { "DE", "Alemania" }, { "FR", "Francia" },
}

local TYRES = { "blando", "medio", "duro", "lluvia" }
local TYRE_W = { blando = 9, medio = 6, duro = 4, lluvia = 14 }
local PARTS = { { "motor", "Motor" }, { "acel", "Aceleración" }, { "vmax", "Velocidad final" }, { "dir", "Dirección" } }
local TEAM_NEW = "Escudería Fénix"

local LARGADA = {
    q = "Largada: ¿arriesgás en la primera curva para pasar autos?",
    o = { { "Arriesgar", { ov = true, i = 0.10, p = 1 } }, { "Conservar", { p = 0 } } },
}

local POOL = {
    { q = "Curva lenta: ¿entrás por dentro o por fuera?",
      o = { { "Por dentro", { p = 2, w = 3, i = 0.05 } }, { "Por fuera", { p = -1, w = -1 } } } },
    { q = "Un rival frena tarde. ¿Atacás?",
      o = { { "Atacar", { p = 3, w = 2, i = 0.08, ov = true } }, { "Esperar", { p = 0, w = -2 } } } },
    { q = "Dudas del desgaste. ¿Apostás a que los neumáticos duran más?",
      o = { { "Apostar que duran", { p = 2, w = 6, i = 0.02 } }, { "Cuidarlos", { p = -1, w = -3 } } } },
    { q = "Pronóstico de cambio de clima. ¿Apostás a lluvia?",
      o = { { "Apostar a lluvia", { rain = true } }, { "Mantener el plan", { p = 0 } } } },
    { q = "Los técnicos recomiendan un nuevo mapa de motor.",
      o = { { "Seguir la recomendación", { p = 1.5, e = -3 } }, { "Ignorarlos", { p = 0 } } } },
    { q = "Radio: el ingeniero pide ritmo ahora.",
      o = { { "Empujar", { p = 3, e = -4, i = 0.06 } }, { "Administrar", { p = -1, e = 1 } } } },
    { q = "Vuelta de ataque: ¿qué modo usás?",
      o = { { "Máximo ritmo", { p = 4, w = 4, e = -5, i = 0.07 } }, { "Vuelta segura", { p = 1, w = 1 } } } },
}

local BRANDS = {
    personal = { "Casco Vortex", "Relojes Kronos", "Gafas Nova", "Ropa Velox" },
    publicidad = { "Bebidas Turbo", "Banco Andino", "Aerolínea Sol", "Cerveza Pista" },
    chisme = { "Revista Paddock Hoy", "Podcast Motor Chisme", "Noticiero Neón" },
}
local GENRE_NAME = { personal = "Marca personal", publicidad = "Publicidad", chisme = "Chismes" }

local REAL = {
    agresivo = { podio = "Ese podio es mío y lo voy a defender en cada carrera.", puntos = "Sumamos puntos, pero necesito mucho más para pelear arriba.", fuera = "El auto no respondió hoy y eso no se va a repetir." },
    neutral = { podio = "Muy buen resultado, el equipo hizo un gran trabajo.", puntos = "Sumamos puntos y seguimos mejorando paso a paso.", fuera = "Hoy no fue nuestro día, analizamos y seguimos." },
    pasivo = { podio = "Estoy feliz, aunque todavía hay mucho por mejorar.", puntos = "Fue un día correcto, nada más.", fuera = "Lo siento por el equipo, aprendemos de esto." },
}
local BIZ = {
    agresivo = { "Le pedí explicaciones a una gaviota. Todavía no me contestó.", "Si el rival me vuelve a tocar, le regalo mi casco." },
    neutral = { "Mi auto tiene nombre propio: se llama Gerardo.", "Desayuné cereal con olor a fórmula uno." },
    pasivo = { "Pensé en ser pescador, pero los peces también me esquivan.", "Escuché un ruido raro en el motor y lo saludé." },
}
local INCIDENTS = {
    "Un pato cruzó la pista en la curva 3. El pato ganó la curva.",
    "Tu alerón quedó con una bolsa de papas pegada. Nadie explica cómo.",
    "Un perro invadió la recta y dejó una pelota en el box rival.",
    "Radio: \"Ingeniero, el volante habla. Pide que lo cuides.\"",
    "Una paloma chocó contra el visor. Se retira por motivos personales.",
}

---------------------------------------------------------------------------
-- Utilidades
---------------------------------------------------------------------------

local function clamp(v, a, b)
    if v < a then return a elseif v > b then return b end
    return v
end
local function rnd(a, b) return a + math.random() * (b - a) end
local function pick(t) return t[math.random(#t)] end
local function shuffle(t)
    local a = {}
    for i, v in ipairs(t) do a[i] = v end
    for i = #a, 2, -1 do
        local j = math.random(i)
        a[i], a[j] = a[j], a[i]
    end
    return a
end
local function K(v) return string.format("$%dk", math.floor(v + 0.5)) end
local function gap(d)
    if d <= 0 then return "—" end
    return string.format("+%.2fs", d)
end
local function mark(v)
    return string.format("[%s]", v)
end

local function findPl(list)
    for _, c in ipairs(list) do if c.pl then return c end end
end

local function sortedCars(cars)
    local o = {}
    for i, c in ipairs(cars) do o[i] = c end
    table.sort(o, function(a, b) return a.cum < b.cum end)
    return o
end

local function indexIn(list, item)
    for i, v in ipairs(list) do if v == item then return i end end
    return 0
end

-- Diagrama ASCII del circuito con posición de los autos (e-ink friendly)
local function trackArt(lap, cars)
    local W, H = 41, 9
    local grid = {}
    for y = 1, H do
        grid[y] = {}
        for x = 1, W do grid[y][x] = " " end
    end
    for a = 0, 355, 5 do
        local rad = math.rad(a)
        local x = math.floor(20 + 17 * math.cos(rad) + 0.5) + 1
        local y = math.floor(5 + 3.6 * math.sin(rad) + 0.5)
        if y >= 1 and y <= H and x >= 1 and x <= W then grid[y][x] = "." end
    end
    local ord = sortedCars(cars)
    local lead = ord[1]
    for _, c in ipairs(cars) do
        local f = (0.5 - (c.cum - lead.cum) / (lap * 0.5)) % 1
        local rad = 2 * math.pi * f
        local x = math.floor(20 + 17 * math.cos(rad) + 0.5) + 1
        local y = math.floor(5 + 3.6 * math.sin(rad) + 0.5)
        if y >= 1 and y <= H and x >= 1 and x <= W then
            grid[y][x] = c.pl and "@" or "*"
        end
    end
    local lines = {}
    for y = 1, H do lines[y] = table.concat(grid[y]) end
    return table.concat(lines, "\n")
end

---------------------------------------------------------------------------
-- Estado
---------------------------------------------------------------------------

local function newState(name, nat)
    local st = {
        name = name, nat = nat, money = 500, pop = 0, podios = 0,
        eng = 100, fuel = 100, tyre = "medio", tyreW = 100,
        parts = { motor = 1, acel = 1, vmax = 1, dir = 1 },
        pend = false, contracts = {}, offers = {},
        ti = 1, team = "Tu Escudería", teamBonus = 0, teamOffered = false,
        grid = nil, strat = 2, lastPos = 22, msg = "",
        rainPct = 0, rainNow = false, rainTxt = "",
    }
    st.table = {}
    for _, d in ipairs(AI) do
        table.insert(st.table, { n = d[1], cc = d[2], team = d[3], r = d[4], pts = 0, pl = false })
    end
    table.insert(st.table, { n = name, cc = nat, team = st.team, r = 0, pts = 0, pl = true })
    return st
end

local function playerRating(st)
    local sum = 0
    for _, lv in pairs(st.parts) do sum = sum + (lv - 1) end
    return 58 + sum * 2.6 + st.teamBonus
end

local function me(st)
    for _, t in ipairs(st.table) do if t.pl then return t end end
end

local function posOf(st)
    local o = {}
    for i, t in ipairs(st.table) do o[i] = t end
    table.sort(o, function(a, b) return a.pts > b.pts end)
    for i, t in ipairs(o) do if t.pl then return i end end
    return 22
end

local function podioIdx(st)
    return math.floor(st.podios * 10 + me(st).pts * 0.5 + st.pop * 0.2 + 0.5)
end

local function payPerRace(st)
    local s = 0
    for _, c in pairs(st.contracts) do s = s + (c and c.pay or 0) end
    return s
end

local function genOffers(st)
    st.offers = {
        { g = "personal", b = pick(BRANDS.personal), pay = math.floor(20 + st.pop * 0.8) },
        { g = "publicidad", b = pick(BRANDS.publicidad), pay = math.floor(35 + st.pop * 1.5) },
        { g = "chisme", b = pick(BRANDS.chisme), pay = 0 },
    }
end

local function rollWeather(st)
    local T = TRACKS[st.ti]
    local p = clamp(T.rain + rnd(-10, 10), 0, 100)
    st.rainPct = math.floor(p + 0.5)
    if p < 40 then
        st.rainNow = false; st.rainTxt = ""
    elseif p > 75 then
        st.rainNow = true; st.rainTxt = math.random() < 0.5 and "poca" or "mucha"
    else
        st.rainNow = math.random() < p / 100
        st.rainTxt = st.rainNow and (math.random() < 0.5 and "poca" or "mucha") or ""
    end
end

---------------------------------------------------------------------------
-- Plugin
---------------------------------------------------------------------------

function F1:init()
    self.settings = LuaSettings:open(DataStorage:getSettingsDir() .. "/f1management.lua")
    self.state = self.settings:readSetting("state")
    self.sess = nil
    math.randomseed(os.time())
    if self.ui and self.ui.menu then
        self.ui.menu:registerToMainMenu(self)
    end
end

function F1:addToMainMenu(menu_items)
    menu_items.f1management = {
        text = _("F1 Management"),
        sorting_hint = "tools",
        sub_item_table = {
            { text = _("Continuar temporada"), callback = function() self:home() end,
              enabled_func = function() return self.state ~= nil end },
            { text = _("Nueva temporada"), callback = function() self:newGame() end },
            { text = _("Borrar partida"), callback = function()
                self.state = nil; self.settings:delSetting("state"); self.settings:flush()
                UIManager:show(InfoMessage:new{ text = _("Partida borrada.") })
              end },
        },
    }
end

function F1:save()
    if not self.state then return end
    self.settings:saveSetting("state", self.state)
    self.settings:flush()
end

function F1:dlg(title, rows)
    if self.dialog then UIManager:close(self.dialog) end
    local btns = {}
    for _, r in ipairs(rows) do
        table.insert(btns, { { text = r[1], callback = r[2] } })
    end
    self.dialog = ButtonDialog:new{ title = title, buttons = btns }
    UIManager:show(self.dialog)
end

function F1:msg(text)
    UIManager:show(InfoMessage:new{ text = text })
end

---------------------------------------------------------------------------
-- Inicio y menús
---------------------------------------------------------------------------

function F1:newGame()
    self.input = InputDialog:new{
        title = _("Nombre del piloto"),
        input = "Piloto",
        buttons = {{
            { text = _("Cancelar"), id = "close", callback = function() UIManager:close(self.input) end },
            { text = _("Siguiente"), is_enter_default = true, callback = function()
                local n = self.input:getInputText()
                if n == nil or n == "" then n = "Piloto" end
                UIManager:close(self.input)
                self:pickNation(n)
            end },
        }},
    }
    UIManager:show(self.input)
    self.input:onShowKeyboard()
end

function F1:pickNation(name)
    local rows = {}
    for _, n in ipairs(NATIONS) do
        table.insert(rows, { n[2] .. " " .. mark(n[1]), function()
            self.state = newState(name, n[1])
            genOffers(self.state)
            self.state.view = nil
            self:save()
            self:home()
        end })
    end
    self:dlg(_("Elegí tu nacionalidad. Empezás en P22 con popularidad 0."), rows)
end

function F1:home()
    local st = self.state
    if not st then self:msg(_("Primero creá una temporada.")) return end
    local T = TRACKS[st.ti]
    local title = string.format(
        "%s %s\nEscudería: %s · Rating: %d\nDinero %s · Pop %d · Pts %d · P%d/22\nPróxima: %s (%s)\nÍndice nivel podio: %d%s",
        st.name, mark(me(st).cc), st.team, math.floor(playerRating(st) + 0.5),
        K(st.money), st.pop, me(st).pts, posOf(st), T.c, T.p, podioIdx(st),
        st.msg ~= "" and ("\n" .. st.msg) or ""
    )
    self:dlg(title, {
        { "1 · Escudería", function() self:garage() end },
        { "2 · Prensa", function() self:press() end },
        { "3 · Tabla clasificatoria", function() self:table() end },
        { "4 · Siguiente carrera", function() self:nextRace() end },
    })
end

function F1:garage()
    local st = self.state
    local title = string.format("ESCUDERÍA · Dinero %s\nLas mejoras son más baratas que las piezas nuevas.", K(st.money))
    local rows = {}
    for _, p in ipairs(PARTS) do
        local key, label = p[1], p[2]
        local lv = st.parts[key]
        table.insert(rows, { string.format("%s nivel %d/5 · Mejorar %s", label, lv, K(120 * lv)), function()
            self:buy("up", key) end })
        table.insert(rows, { string.format("%s · Reemplazar +2 %s", label, K(350 * lv)), function()
            self:buy("repl", key) end })
    end
    table.insert(rows, { string.format("Reparar motor (%d%%) %s", math.floor(st.eng), K((100 - st.eng) * 3)), function() self:buy("fix") end })
    table.insert(rows, { "Motor nuevo (nivel 5) 900k", function() self:buy("eng") end })
    table.insert(rows, { "Volver", function() self:home() end })
    self:dlg(title, rows)
end

function F1:buy(kind, key)
    local st = self.state
    local cost, apply = 0, nil
    if kind == "up" then
        cost = 120 * st.parts[key]
        apply = function() st.parts[key] = st.parts[key] + 1 end
    elseif kind == "repl" then
        cost = 350 * st.parts[key]
        apply = function() st.parts[key] = math.min(5, st.parts[key] + 2) end
    elseif kind == "eng" then
        cost = 900
        apply = function() st.parts.motor = 5 end
    elseif kind == "fix" then
        cost = (100 - st.eng) * 3
        apply = function() st.eng = 100 end
    end
    if cost <= 0 then return self:garage() end
    if st.money < cost then
        self:msg(_("Fondos insuficientes."))
        return self:garage()
    end
    st.money = st.money - cost
    apply()
    if kind ~= "fix" then
        st.pend = true
        self:msg(_("Mejora instalada. Se recomienda probarla en la qualy: puede demorar la largada."))
    end
    self:save()
    self:garage()
end

function F1:press()
    local st = self.state
    local lines = { "PRENSA · un contrato por género. Aceptar cobra por carrera." }
    for g, label in pairs(GENRE_NAME) do
        local c = st.contracts[g]
        table.insert(lines, label .. ": " .. (c and (c.b .. " · " .. (c.pay > 0 and (K(c.pay) .. "/carrera") or "sin pago")) or "vacío"))
    end
    local rows = {}
    for g, label in pairs(GENRE_NAME) do
        if st.contracts[g] then
            table.insert(rows, { "Cancelar " .. label, function()
                st.contracts[g] = nil; self:save(); self:press() end })
        end
    end
    for i, o in ipairs(st.offers) do
        table.insert(rows, { string.format("Aceptar %s: %s %s", GENRE_NAME[o.g], o.b, o.pay > 0 and K(o.pay) or "(nota)"), function()
            self:acceptOffer(i) end })
        table.insert(rows, { "Declinar " .. o.b, function()
            table.remove(st.offers, i); self:save(); self:press() end })
    end
    table.insert(rows, { "Volver", function() self:home() end })
    self:dlg(table.concat(lines, "\n"), rows)
end

function F1:acceptOffer(i)
    local st = self.state
    local o = st.offers[i]
    if not o then return self:press() end
    local old = st.contracts[o.g]
    st.contracts[o.g] = { g = o.g, b = o.b, pay = o.pay }
    table.remove(st.offers, i)
    if o.g == "chisme" then
        local d = math.floor(rnd(-3, 10) + 0.5)
        st.pop = math.max(0, st.pop + d)
        st.msg = "La nota salió publicada. ¿Verdadera o falsa? Nadie lo sabe."
        self:msg(string.format("Popularidad %s%d", d >= 0 and "+" or "", d))
    else
        st.msg = old and ("Reemplazaste " .. old.b .. " por " .. o.b) or ("Contrato aceptado: " .. o.b)
    end
    self:save()
    self:press()
end

function F1:table()
    local st = self.state
    local o = {}
    for i, t in ipairs(st.table) do o[i] = t end
    table.sort(o, function(a, b) return a.pts > b.pts end)
    local lines = { "TABLA CLASIFICATORIA" }
    for i, t in ipairs(o) do
        table.insert(lines, string.format("%2d %s %-16s %-14s %3d%s", i, mark(t.cc), t.n, t.team, t.pts, t.pl and " <-" or ""))
    end
    table.insert(lines, string.format("Popularidad %d · Índice podio %d (%d podios)", st.pop, podioIdx(st), st.podios))
    self:dlg(table.concat(lines, "\n"), { { "Volver", function() self:home() end } })
end

function F1:nextRace()
    local st = self.state
    local T = TRACKS[st.ti]
    local title = string.format("%s · %s\nRécord de vuelta: %s\n%s (%s) %d\n\n%s",
        T.c, T.p, T.rt, T.r, T.rc, T.ry, trackArt(T.lap, {}))
    self:dlg(title, {
        { "Ir a qualy", function() self:preSession("quali") end },
        { "Volver", function() self:home() end },
    })
end

---------------------------------------------------------------------------
-- Pre-sesión (clima, neumáticos, estrategia)
---------------------------------------------------------------------------

function F1:preSession(kind)
    local st = self.state
    st.preType = kind
    rollWeather(st)
    local T = TRACKS[st.ti]
    local title = string.format("%s · %s\nProbabilidad de lluvia: %d%% → %s\nNeumáticos actuales: %s",
        kind == "quali" and "QUALY" or "CARRERA", T.c, st.rainPct,
        st.rainNow and ("LLUEVE (" .. st.rainTxt .. ")") or "Pista seca", st.tyre)
    local rows = {}
    for _, t in ipairs(TYRES) do
        table.insert(rows, { (st.tyre == t and "› " or "") .. t:sub(1, 1):upper() .. t:sub(2), function()
            st.tyre = t; self:preSession(kind) end })
    end
    if kind == "quali" then
        table.insert(rows, { (st.strat == 1 and "› " or "") .. "Estrategia conservadora", function() st.strat = 1; self:preSession(kind) end })
        table.insert(rows, { (st.strat == 2 and "› " or "") .. "Estrategia agresiva", function() st.strat = 2; self:preSession(kind) end })
    end
    if st.pend then title = title .. "\n⚠ Mejora sin probar: puede demorar la largada." end
    table.insert(rows, { kind == "quali" and "Largar qualy" or "Largar carrera", function() self:startSession(kind) end })
    table.insert(rows, { "Volver", function() self:nextRace() end })
    self:dlg(title, rows)
end

---------------------------------------------------------------------------
-- Motor de sesión
---------------------------------------------------------------------------

function F1:startSession(kind)
    local st = self.state
    if kind == "quali" then
        st.eng = 100; st.fuel = 100; st.tyreW = 100
    else
        st.fuel = 100; st.tyreW = 100
    end
    local cars = {}
    for _, t in ipairs(st.table) do
        table.insert(cars, {
            n = t.n, cc = t.cc, r = t.pl and playerRating(st) or t.r, pl = t.pl, cum = 0,
        })
    end
    if kind == "race" and st.grid then
        for _, c in ipairs(cars) do
            c.cum = (indexIn(st.grid, c.n) - 1) * 0.35
        end
    end
    local sess = { type = kind, seg = 0, cars = cars, pit = false,
                   mod = { p = 0, w = 0, e = 0, i = 0, ov = false }, log = {} }
    if kind == "race" then
        sess.decs = { LARGADA }
        for _, d in ipairs(shuffle(POOL)) do
            if #sess.decs >= 7 then break end
            table.insert(sess.decs, d)
        end
    else
        sess.decs = {}
        for _, d in ipairs(shuffle(POOL)) do
            if #sess.decs >= 7 then break end
            table.insert(sess.decs, d)
        end
    end
    if kind == "race" and st.pend then
        st.pend = false
        if math.random() < 0.5 then
            findPl(cars).cum = findPl(cars).cum + 2
            table.insert(sess.log, "Mejora sin probar: demora en la largada (+2s)")
        end
    end
    self.sess = sess
    self:save()
    self:sessionScreen()
end

function F1:runSeg()
    local st, s = self.state, self.sess
    local T = TRACKS[st.ti]
    local seg = T.lap / 4
    local m = s.mod
    local pl = findPl(s.cars)
    local before = indexIn(sortedCars(s.cars), pl)
    local wrong
    if st.rainNow then
        wrong = (st.tyre ~= "lluvia") and -14 or 0
    else
        wrong = (st.tyre == "lluvia") and -12 or 0
    end
    local stratBonus = 0
    if s.type == "quali" then stratBonus = (st.strat == 2) and 2.5 or -1 end
    local myPerf = pl.r + m.p - (100 - st.tyreW) * 0.05 - (100 - st.eng) * 0.06
                   - ((st.fuel < 12) and 8 or 0) + wrong + stratBonus
    for _, c in ipairs(s.cars) do
        local perf = c.pl and myPerf or (c.r + rnd(-2.5, 2.5))
        c.cum = c.cum + seg * (1 + (100 - perf) * 0.02) + rnd(-0.3, 0.3)
    end
    if m.ov then pl.cum = pl.cum - rnd(0, 1.2) end
    if math.random() < 0.04 + m.i then
        pl.cum = pl.cum + rnd(3, 8)
        st.incident = pick(INCIDENTS)
        table.insert(s.log, "Incidente")
    end
    local mult = (st.rainNow and st.tyre ~= "lluvia") and 2 or 1
    if s.type == "quali" then mult = mult * 0.6 end
    local wear = TYRE_W[st.tyre] * mult + m.w
    st.tyreW = clamp(st.tyreW - wear, 0, 100)
    st.fuel = clamp(st.fuel - ((s.type == "race") and 12.5 or 3), 0, 100)
    st.eng = clamp(st.eng + m.e - ((s.type == "race") and 1.2 or 0.5), 0, 100)
    local after = indexIn(sortedCars(s.cars), pl)
    if after < before then
        table.insert(s.log, "Adelantaste: ahora sos P" .. after)
    elseif after > before then
        table.insert(s.log, "Te pasaron: ahora sos P" .. after)
    end
    s.mod = { p = 0, w = 0, e = 0, i = 0, ov = false }
end

function F1:sessionScreen()
    local st, s = self.state, self.sess
    local T = TRACKS[st.ti]
    local ord = sortedCars(s.cars)
    local mine = findPl(s.cars)
    local pos = indexIn(ord, mine)
    local ahead, behind = ord[pos - 1], ord[pos + 1]
    local lines = {
        string.format("%s · %s · tramo %d/8 · estás P%d", s.type == "quali" and "QUALY" or "CARRERA", T.c, math.min(s.seg + 1, 8), pos),
    }
    if ahead then
        table.insert(lines, string.format("Adelante: %s %s (-%s)", mark(ahead.cc), ahead.n, string.format("%.2fs", mine.cum - ahead.cum)))
    else
        table.insert(lines, "Adelante: liderás")
    end
    if behind then
        table.insert(lines, string.format("Atrás: %s %s (+%s)", mark(behind.cc), behind.n, string.format("%.2fs", behind.cum - mine.cum)))
    else
        table.insert(lines, "Atrás: sos el último")
    end
    table.insert(lines, string.format("Motor %d%% · Neumáticos %s %d%% · Combustible %d%%",
        math.floor(st.eng), st.tyre, math.floor(st.tyreW), math.floor(st.fuel)))
    table.insert(lines, trackArt(T.lap, s.cars))
    if st.incident then
        table.insert(lines, "¡INCIDENTE! " .. st.incident)
        st.incident = nil
    end
    local rows = {}
    if s.seg < 7 then
        local d = s.decs[s.seg + 1]
        table.insert(lines, string.format("Decisión %d de 7: %s", s.seg + 1, d.q))
        for i, o in ipairs(d.o) do
            table.insert(rows, { o[1], function() self:choose(i) end })
        end
    else
        table.insert(lines, "Último tramo.")
        table.insert(rows, { "Cruzar la bandera", function() self:finish() end })
    end
    if s.type == "race" and not s.pit then
        table.insert(rows, { "Entrar a pits (obligatorio 1 vez)", function() self:pitMenu() end })
    end
    if #s.log > 0 then
        table.insert(lines, "Registro: " .. s.log[#s.log])
    end
    self:dlg(table.concat(lines, "\n"), rows)
end

function F1:choose(i)
    local s = self.sess
    local d = s.decs[s.seg + 1]
    local e = d.o[i][2]
    local m = s.mod
    m.p = m.p + (e.p or 0)
    m.w = m.w + (e.w or 0)
    m.e = m.e + (e.e or 0)
    m.i = m.i + (e.i or 0)
    if e.ov then m.ov = true end
    if e.rain then m.p = m.p + (self.state.rainNow and 4 or -4) end
    table.insert(s.log, "Decisión: " .. d.o[i][1])
    self:runSeg()
    s.seg = s.seg + 1
    self:sessionScreen()
end

function F1:pitMenu()
    local st = self.state
    local rows = {}
    for _, t in ipairs(TYRES) do
        if t ~= st.tyre then
            table.insert(rows, { t:sub(1, 1):upper() .. t:sub(2), function() self:doPit(t) end })
        end
    end
    table.insert(rows, { "Seguir en pista", function() self:sessionScreen() end })
    self:dlg(string.format("PITS · el combustible se llena. Neumáticos actuales: %s. Elegí otros.", st.tyre), rows)
end

function F1:doPit(t)
    local st, s = self.state, self.sess
    st.tyre = t
    st.tyreW = 100
    st.fuel = 100
    findPl(s.cars).cum = findPl(s.cars).cum + 20
    s.pit = true
    table.insert(s.log, "Pits: neumáticos " .. t .. ", combustible lleno (+20s)")
    self:sessionScreen()
end

function F1:finish()
    local st, s = self.state, self.sess
    self:runSeg()
    local mine = findPl(s.cars)
    if s.type == "race" and not s.pit then
        mine.cum = mine.cum + 25
    end
    local ord = sortedCars(s.cars)
    local pos = indexIn(ord, mine)
    local lines = {}
    for i, c in ipairs(ord) do
        table.insert(lines, string.format("%2d %s %-16s %s", i, mark(c.cc), c.n,
            i > 1 and gap(c.cum - ord[1].cum) or ""))
    end
    if s.type == "quali" then
        st.grid = {}
        for i, c in ipairs(ord) do st.grid[i] = c.n end
        st.pend = false
        self.sess = nil
        self:save()
        self:msg(string.format("QUALY terminada. Largás desde la P%d.", pos))
        return self:preSession("race")
    end
    for i, c in ipairs(ord) do
        if i <= 10 then
            for _, t in ipairs(st.table) do
                if t.n == c.n then t.pts = t.pts + PTS[i] end
            end
        end
    end
    if pos <= 3 then st.podios = st.podios + 1 end
    local earned = payPerRace(st) + (PTS[pos] or 0) * 5
    st.money = st.money + earned
    st.pop = math.floor(st.pop + (pos <= 3 and 5 or pos <= 10 and 2 or 0.5) + 0.5)
    st.lastPos = pos
    st.ti = (st.ti % #TRACKS) + 1
    genOffers(st)
    st.msg = string.format("Carrera: P%d · Ingreso %s", pos, K(earned))
    self.sess = nil
    self:save()
    UIManager:show(InfoMessage:new{
        text = string.format("FIN · Tu posición: P%d\n\n%s", pos, table.concat(lines, "\n")),
    })
    self:pressConf()
end

---------------------------------------------------------------------------
-- Conferencia de prensa
---------------------------------------------------------------------------

function F1:pressConf()
    local st = self.state
    local p = st.lastPos
    local cat = p <= 3 and "podio" or (p <= 10 and "puntos" or "fuera")
    local answers = {}
    for _, t in ipairs({ "agresivo", "neutral", "pasivo" }) do
        local biz = math.random() >= 0.7
        table.insert(answers, { t = t, biz = biz, txt = biz and pick(BIZ[t]) or REAL[t][cat] })
    end
    answers = shuffle(answers)
    local rows = {}
    for i, a in ipairs(answers) do
        table.insert(rows, { a.txt, function() self:answer(a) end })
    end
    self:dlg("CONFERENCIA DE PRENSA · ¿Qué respondés?", rows)
end

function F1:answer(a)
    local st = self.state
    st.pop = math.floor(st.pop + (a.t == "agresivo" and 3 or a.t == "neutral" and 2 or 1) + (a.biz and 2 or 0) + 0.5)
    self:save()
    if not st.teamOffered and st.pop >= 60 and me(st).pts >= 30 then
        self:dlg(TEAM_NEW .. " te ofrece un asiento y +5 de rendimiento. ¿Aceptás?", {
            { "Aceptar", function() self:joinTeam(true) end },
            { "Declinar", function() self:joinTeam(false) end },
        })
    else
        self:home()
    end
end

function F1:joinTeam(yes)
    local st = self.state
    st.teamOffered = true
    if yes then
        st.team = TEAM_NEW
        st.teamBonus = 5
        me(st).team = st.team
    end
    self:save()
    self:home()
end

return F1

